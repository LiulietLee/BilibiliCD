//
//  HistoryViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 21/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import SWRevealViewController

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, SetHistoryNumDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menu: UIBarButtonItem!
    fileprivate let dataModel = CoreDataModel()
    fileprivate var history = [History]() {
        didSet {
            DispatchQueue.main.async {
                self.loadingView.dismiss()
                if self.history.count != 0 {
                    self.tableView.reloadData()
                } else {
                    self.setLabel()
                    self.showLabel()
                }
            }
        }
    }
    fileprivate let nothingLabel = UILabel()
    fileprivate var loadingView: LoadingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = LoadingView(frame: view.bounds)
        loadingView.color = .tianyiBlue
        view.addSubview(loadingView)
        view.bringSubview(toFront: loadingView)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.dataModel.refreshHistory()
            self.history = self.dataModel.history
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        menu.target = revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
    
    fileprivate func setLabel() {
        nothingLabel.text = "这里空空如也"
        nothingLabel.textColor = .tianyiBlue
        nothingLabel.font = UIFont(name: "Avenir", size: 32.0)
        nothingLabel.translatesAutoresizingMaskIntoConstraints = false
        nothingLabel.textAlignment = .center
        
        view.addSubview(nothingLabel)
        
        let midXCon = NSLayoutConstraint(item: nothingLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let midYCon = NSLayoutConstraint(item: nothingLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        
        view.addConstraint(midXCon)
        view.addConstraint(midYCon)
    }
    
    fileprivate func showLabel() {
        nothingLabel.isHidden = false
        view.bringSubview(toFront: nothingLabel)
    }
    
    fileprivate func hideLabel() {
        nothingLabel.isHidden = true
        view.sendSubview(toBack: nothingLabel)
    }
    
    @IBAction func clearButtonTapped(_ sender: UIBarButtonItem) {
        let dialog = LLDialog()
        dialog.title = "乃确定不是手滑了么"
        dialog.message = "真的要清空历史记录嘛？"
        dialog.setPositiveButton(withTitle: "我手滑了")
        dialog.setNegativeButton(withTitle: "确认清空", target: self, action: #selector(clearHistory))
        dialog.show()
    }
    
    @objc fileprivate func clearHistory() {
        dataModel.clearHistory()
        history = []
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        if history.count == 0 {
        //            setLabel()
        //            showLabel()
        //        }
        
        return history.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryCell
        cell.titleLabel.text = history[indexPath.row].title!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd hh:mm"
        cell.dateLabel.text = formatter.string(from: history[indexPath.row].date! as Date)
        
        DispatchQueue.global(qos: .userInteractive).async {
            let image = UIImage(data: self.history[indexPath.row].image! as Data, scale: 1.0)!
            DispatchQueue.main.async {
                cell.coverView.image = image
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let item = history[indexPath.row]
        dataModel.deleteHistory(item)
        history = dataModel.history
        tableView.reloadData()
    }
    
    func historyNumLimitChanged() {
        dataModel.refreshHistory()
        history = dataModel.history
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "set limit" {
            if let vc = segue.destination as? SetHistoryNumViewController {
                vc.delegate = self
                if let controller = vc.popoverPresentationController {
                    controller.delegate = self
                }
            }
        } else if segue.identifier == "detail" {
            if let vc = segue.destination as? ImageViewController,
                let cell = sender as? HistoryCell,
                let indexPath = tableView.indexPath(for: cell) {
                let item = history[indexPath.row]
                vc.cover = BilibiliCover(item.av!)
                vc.itemFromHistory = item
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
