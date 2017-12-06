//
//  SourceTableViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 10/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class SourceTableViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    fileprivate let list: [(name: String, url: String)] = [
        ("Liuliet.Lee/LLDialog", "https://github.com/LiulietLee/LLDialog/blob/master"),
        ("ApolloZhu/MaterialKit", "https://github.com/ApolloZhu/MaterialKit/blob/master"),
        ("John-Lluch/SWRevealViewController", "https://github.com/John-Lluch/SWRevealViewController/blob/master"),
        ("maximbilan/iOS-Shared-CoreData-Storage-for-App-Groups", "https://github.com/maximbilan/iOS-Shared-CoreData-Storage-for-App-Groups"),
        ("ph1ps/Nudity-CoreML", "https://github.com/ph1ps/Nudity-CoreML"),
        ("marcosgriselli/ViewAnimator", "https://github.com/marcosgriselli/ViewAnimator"),
        ("imxieyi/waifu2x-ios", "https://github.com/imxieyi/waifu2x-ios"),
        ("Ekhoo/Device", "https://github.com/Ekhoo/Device")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton.target = revealViewController()
        menuButton.action = #selector(revealViewController().revealToggle(_:))
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIApplication.shared.open(URL(string: list[indexPath.row].url)!, options: [:], completionHandler: nil)
    }

}
