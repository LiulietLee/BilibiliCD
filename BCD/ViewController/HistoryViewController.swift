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

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, SetHistoryNumDelegate, MotionDetectorDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menu: UIBarButtonItem!
    private let motionDetector = MotionDetector()
    private let manager = HistoryManager()
    private var isAnimatedOnce = false
    private var history = [History]() {
        didSet {
            DispatchQueue.main.async {
                self.loadingView.dismiss()
                
                if self.history.count != 0 {
                    self.tableView.reloadData()
                } else {
                    self.setLabel()
                    self.showLabel()
                }
                
                if !self.isAnimatedOnce {
                    self.animateView()
                }
            }
        }
    }
    private var isShowingFullHistory = false {
        didSet {
            if oldValue {
                navigationController?.navigationBar.barTintColor = .tianyiBlue
            } else {
                navigationController?.navigationBar.barTintColor = .black
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
            self.history = self.manager.getHistory()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        menu.target = revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        
        if needToDisplayHisTut {
            showTutMessage()
        }
        
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
    
    private func showTutMessage() {
        let dialog = LLDialog()
        dialog.title = "(=・ω・=)"
        dialog.message = "想看看历史记录「里世界」的使用方法么？"
        dialog.setNegativeButton(withTitle: "不想")
        dialog.setPositiveButton(withTitle: "好的", target: self, action: #selector(showTutorial))
        dialog.show()
    }
    
    @objc private func showTutorial() {
        let vc = HisTutViewController()
        present(vc, animated: true, completion: nil)
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
    
    @IBAction func clearButtonTapped(_ sender: UIBarButtonItem) {
        let dialog = LLDialog()
        dialog.title = "乃确定不是手滑了么"
        dialog.message = "真的要清空历史记录嘛？"
        dialog.setPositiveButton(withTitle: "我手滑了")
        dialog.setNegativeButton(withTitle: "确认清空", target: self, action: #selector(clearHistory))
        dialog.show()
    }
    
    @objc private func clearHistory() {
        manager.clearHistory()
        history = []
        tableView.reloadData()
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
        
        if !history[indexPath.row].isHidden || isShowingFullHistory {
            if history[indexPath.row].title != nil {
                cell.titleLabel.text = history[indexPath.row].title!
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy.MM.dd hh:mm"
                cell.dateLabel.text = formatter.string(from: history[indexPath.row].date! as Date)
                let item = history[indexPath.row]
                DispatchQueue.global(qos: .userInteractive).async {
                    let image = item.uiImage
                    DispatchQueue.main.async { [weak self] in
                        let indexOfCell = self?.tableView.indexPath(for: cell)
                        if indexOfCell == indexPath {
                            cell.coverView.image = image
                        }
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
        let hide = UITableViewRowAction(style: .normal, title: hideString) { action, index in
            self.manager.changeIsHiddenOf(item)
            self.history = self.manager.getHistory()
            self.tableView.reloadData()
        }
        hide.backgroundColor = .lightGray
        
        let delete = UITableViewRowAction(style: .normal, title: "删除") { action, index in
            self.manager.deleteHistory(item)
            self.history = self.manager.getHistory()
            self.tableView.deleteRows(at: [editActionsForRowAt], with: .left)
        }
        delete.backgroundColor = .red
        
        return [delete, hide]
    }
    
    func historyNumLimitChanged() {
        history = manager.getHistory()
        tableView.reloadData()
    }
    
    func openInsideWorld() {
        navigationController?.navigationBar.barTintColor = .black
        isShowingFullHistory = true
        tableView.reloadData()
        motionDetector.endDetect()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "set limit",
            let vc = segue.destination as? SetHistoryNumViewController {
            vc.delegate = self
            vc.isShowingFullHistory = isShowingFullHistory
            vc.popoverPresentationController?.delegate = self
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
            let item = history[indexPath.row]
            if item.isHidden { return false }
        }
        return true
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
