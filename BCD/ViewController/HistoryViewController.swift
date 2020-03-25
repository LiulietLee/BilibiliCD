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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideCellsIfNeeded),
            name: UIApplication.willResignActiveNotification,
            object: nil
        ) 
    }
    
    @objc private func hideCellsIfNeeded() {
        if isShowingFullHistory {
            isShowingFullHistory = false
        }
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
            DispatchQueue.global(qos: .userInteractive).async {
                #warning("TODO: UISreen scale")
                let image = item.image!.toImage(size: CGSize(width: 134.0, height: 84.0))!
                DispatchQueue.main.async { [weak self] in
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let item = history[editActionsForRowAt.row]
        
        var hideString = "隐藏"
        if item.isHidden {
            if !isShowingFullHistory {
                return []
            }
            hideString = "显示"
        }
        let hide = UITableViewRowAction(style: .normal, title: hideString) {
            [weak self] action, index in
            guard let self = self else { return }
            self.manager.toggleIsHidden(of: item)
            self.history = self.manager.getHistory()
            self.tableView.reloadData()
        }
        hide.backgroundColor = .lightGray
        
        let delete = UITableViewRowAction(style: .normal, title: "删除") {
            [weak self ]action, index in
            guard let self = self else { return }
            self.manager.deleteHistory(item)
            self.history = self.manager.getHistory()
            self.tableView.deleteRows(at: [editActionsForRowAt], with: .left)
        }
        delete.backgroundColor = .systemRed
        
        return [delete, hide]
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
