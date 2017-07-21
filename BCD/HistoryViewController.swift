//
//  HistoryViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 21/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menu: UIBarButtonItem!
    fileprivate let dataModel = CoreDataModel()
    fileprivate var history = [History]()

    override func viewWillAppear(_ animated: Bool) {
        history = dataModel.getHistory()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        menu.target = revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
    
    @IBAction func clearButtonTapped(_ sender: UIBarButtonItem) {
        // todo
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // todo
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryCell
        cell.titleLabel.text = history[indexPath.row].title!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd hh:mm"
        cell.dateLabel.text = formatter.string(from: history[indexPath.row].date! as Date)
        cell.coverView.image = UIImage(data: history[indexPath.row].image! as Data, scale: 1.0)!
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
