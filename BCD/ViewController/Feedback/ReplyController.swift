//
//  ReplyController.swift
//  BCD
//
//  Created by Liuliet.Lee on 15/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit

class ReplyController: UIViewController, UITableViewDataSource, UITableViewDelegate, EditControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newReplyButton: UIButton!
    
    private var reply = [Reply]()
    private var commentProvider = CommentProvider()
    var comment: Comment? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if comment == nil {
            // TODO
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        newReplyButton.layer.masksToBounds = true
        newReplyButton.layer.cornerRadius = 28.0

        commentProvider.getReplies(comment: comment!, page: 0) { [weak self] (data) in
            guard let self = self, let list = data else { return }
            self.reply = list
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reply.count + (comment == nil ? 0 : 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! CommentCell
            
            cell.data = comment!
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reply", for: indexPath) as! ReplyCell
            
            cell.data = reply[indexPath.row - 1]
            
            return cell
        }
    }
    
    func editFinished(username: String, content: String) {
        print("- \(username):\n\(content)")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditController {
            vc.delegate = self
            vc.model = .reply
            vc.currentComment = comment
        }
    }
}
