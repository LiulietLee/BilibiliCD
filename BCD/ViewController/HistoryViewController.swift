//
//  HistoryViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 21/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import SWRevealViewController
import ViewAnimator
import LLDialog

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MotionDetectorDelegate, HistoryLimitDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menu: UIBarButtonItem!
    private let motionDetector = MotionDetector()
    private let manager = HistoryManager()
    private var isAnimatedOnce = false
    private var history = [History]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.loadingView.dismiss()
                
                if self.history.isEmpty {
                    self.setLabel()
                    self.showLabel()
                } else {
                    self.tableView.reloadData()
                }
                
                if !self.isAnimatedOnce {
                    self.animateView()
                }
            }
        }
    }
    private var isShowingFullHistory = false {
        didSet {
            if isShowingFullHistory {
                navigationController?.navigationBar.barTintColor = .black
            } else {
                navigationController?.navigationBar.barTintColor = .tianyiBlue
            }
            tableView.reloadData()
        }
    }
    private let nothingLabel = UILabel()
    private var loadingView: LoadingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = LoadingView(frame: view.bounds)
        loadingView.color = .tianyiBlue
        view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in guard let self = self else { return }
            self.history = self.manager.getHistory()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        menu.target = revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        
        promptToShowTutorialIfNeeded()
        
        motionDetector.delegate = self
        motionDetector.beginDetect()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideCellsIfNeeded),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func hideCellsIfNeeded() {
        if isShowingFullHistory {
            isShowingFullHistory = false
        }
    }

    @objc private func toggleShowingFullHistory() {
        isShowingFullHistory.toggle()
    }

    override var keyCommands: [UIKeyCommand] {
        #if targetEnvironment(simulator)
        let flags: UIKeyModifierFlags = [.command, .shift, .control]
        #else
        let flags: UIKeyModifierFlags = [.command, .shift]
        #endif
        return [UIKeyCommand(input: "a", modifierFlags: flags, action: #selector(toggleShowingFullHistory))]
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func animateView() {
        let type = AnimationType.from(direction: .bottom, offset: ViewAnimatorConfig.offset)
        view.animateTableView(type: type)
        isAnimatedOnce = true
    }
    
    private func promptToShowTutorialIfNeeded() {
        guard needToDisplayHistoryTutorial else { return }
        
        LLDialog()
            .set(title: "(=・ω・=)")
            .set(message: "想看看历史记录「里世界」的使用方法么？")
            .setNegativeButton(withTitle: "不想")
            .setPositiveButton(withTitle: "好的", target: self, action: #selector(showTutorial))
            .show()
    }
    
    @objc private func showTutorial() {
        let vc = HisTutViewController()
        present(vc, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionDetector.endDetect()
    }
    
    private func setLabel() {
        nothingLabel.text = "这里空空如也"
        nothingLabel.textColor = .tianyiBlue
        nothingLabel.font = UIFont(name: "Avenir", size: 32.0)
        nothingLabel.translatesAutoresizingMaskIntoConstraints = false
        nothingLabel.textAlignment = .center
        
        view.addSubview(nothingLabel)
        
        let midXCon = nothingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let midYCon = nothingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        view.addConstraint(midXCon)
        view.addConstraint(midYCon)
    }
    
    private func showLabel() {
        nothingLabel.isHidden = false
        view.bringSubviewToFront(nothingLabel)
    }
    
    private func hideLabel() {
        nothingLabel.isHidden = true
        view.sendSubviewToBack(nothingLabel)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryCell
        let item = history[indexPath.row]

        if !item.isHidden || isShowingFullHistory {
            guard let title = item.title else {
                cell.titleLabel.text = "Error: \(indexPath.row)"
                return cell
            }
            cell.titleLabel.text = title
            cell.dateLabel.text = DateFormatter.shortStyle.string(from: item.date!)
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                let image = item.image!.toImage()!
                DispatchQueue.main.async {
                    if indexPath == self?.tableView.indexPath(for: cell) {
                        cell.coverView.image = image
                    }
                }
            }
        } else {
            cell.titleLabel.text = "[数据删除]"
            cell.dateLabel.text = "[数据删除]"
            cell.coverView.image = #imageLiteral(resourceName: "sadpanda")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = history[indexPath.row]
        if item.isHidden && !isShowingFullHistory {
            return nil
        }
        let hideActionTitle = item.isHidden ? "显示" : "隐藏"
        let hide = UIContextualAction(style: .normal, title: hideActionTitle) {
            [weak self] (contextualAction, view, completionHandler) in
            self?.toggleIsHidden(for: indexPath)
            completionHandler(self != nil)
        }
        let delete = UIContextualAction(style: .destructive, title: "删除") {
            [weak self] (contextualAction, view, completionHandler) in
            self?.delete(at: indexPath)
            completionHandler(self != nil)
        }
        return UISwipeActionsConfiguration(actions: [delete, hide])
    }

    @available(iOS, deprecated: 13.0)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let item = history[indexPath.row]
        var hideString = "隐藏"
        if item.isHidden {
            if !isShowingFullHistory {
                return []
            }
            hideString = "显示"
        }
        let hide = UITableViewRowAction(style: .normal, title: hideString) {
            [weak self] action, index in
            self?.toggleIsHidden(for: index)
        }
        hide.backgroundColor = .lightGray
        
        let delete = UITableViewRowAction(style: .destructive, title: "删除") {
            [weak self] action, index in
            self?.delete(at: index)
        }

        return [delete, hide]
    }

    private func toggleIsHidden(for indexPath: IndexPath) {
        let item = history[indexPath.row]
        manager.toggleIsHidden(of: item)
        history = manager.getHistory()
        tableView.reloadData()
    }

    private func delete(at indexPath: IndexPath) {
        let item = history[indexPath.row]
        manager.deleteHistory(item)
        history = manager.getHistory()
        tableView.deleteRows(at: [indexPath], with: .left)
    }
    
    func historyChanged() {
        history = manager.getHistory()
        tableView.reloadData()
    }
    
    func openInsideWorld() {
        isShowingFullHistory = true
        motionDetector.endDetect()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "set limit",
            let vc = segue.destination as? SettingViewController {
            vc.delegate = self
        } else if segue.identifier == "detail",
            let vc = segue.destination as? ImageViewController,
            let cell = sender as? HistoryCell,
            let indexPath = tableView.indexPath(for: cell) {
            let item = history[indexPath.row]
            vc.cover = BilibiliCover(item.av!)
            vc.itemFromHistory = item
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if !isShowingFullHistory,
            identifier == "detail",
            let cell = sender as? HistoryCell,
            let indexPath = tableView.indexPath(for: cell) {
            return !history[indexPath.row].isHidden
        }
        return true
    }

}
