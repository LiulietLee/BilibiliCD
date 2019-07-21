//
//  FeedbackController.swift
//  BCD
//
//  Created by Liuliet.Lee on 11/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit

class FeedbackController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newCommentButton: UIButton!
    
    private var comments = [Comment]()
    private let commentProvider = CommentProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        newCommentButton.layer.masksToBounds = true
        newCommentButton.layer.cornerRadius = 28.0
        
        menuButton.target = revealViewController()
        menuButton.action = #selector(revealViewController().revealToggle(_:))
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        
        commentProvider.getComments(page: 0) { [weak self] (data) in
            guard let self = self, let list = data else { return }
            self.comments = list
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
        
        cell.data = comments[indexPath.row]
        
        return cell
    }
    
    @IBAction func helpButtonTapped(_ sender: UIBarButtonItem) {
        // TODO
    }
    
    func editFinished(username: String, content: String) {
        print("- \(username):\n\(content)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if let vc = segue.destination as? ReplyController,
            let cell = sender as? UITableViewCell,
            let index = tableView.indexPath(for: cell),
            comments.count > index.row {
            vc.comment = comments[index.row]
        } else if let vc = segue.destination as? EditController {
            vc.delegate = self
            vc.model = .comment
        }
    }
    
}
