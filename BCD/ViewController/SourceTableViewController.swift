//
//  SourceTableViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 10/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

private struct GitHubRepo: ExpressibleByStringLiteral {
    let name: String

    public init(stringLiteral value: StringLiteralType) {
        self.name = value
    }
    
    var url: URL {
        return URL(string: "https://github.com/\(name)")!
    }
}

class SourceTableViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    private let list: [GitHubRepo] = [
        "LiulietLee/BilibiliCD",
        "LiulietLee/LLDialog",
        "LiulietLee/bcd-backend",
        "ApolloZhu/MaterialKit",
        "John-Lluch/SWRevealViewController",
        "maximbilan/iOS-Shared-CoreData-Storage-for-App-Groups",
        "ph1ps/Nudity-CoreML",
        "marcosgriselli/ViewAnimator",
        "imxieyi/waifu2x-ios",
        "ApolloZhu/BilibiliKit"
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
        UIApplication.shared.open(list[indexPath.row].url)
    }
}
