//
//  AboutViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 12/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class AboutViewController: UITableViewController {

    @IBOutlet weak var menu: UIBarButtonItem!
    fileprivate let developers = ["https://space.bilibili.com/4056345/#!/",
                                  "http://shallweitalk.com/#"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menu.target = revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let url = developers[indexPath.row]
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
    }
}