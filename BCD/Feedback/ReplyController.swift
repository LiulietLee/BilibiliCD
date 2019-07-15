//
//  ReplyController.swift
//  BCD
//
//  Created by Liuliet.Lee on 15/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit

class ReplyController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

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
            
            cell.username.text = comment!.username
            cell.content.text = comment!.content
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reply", for: indexPath) as! ReplyCell
            
            let row = indexPath.row - 1
            cell.username.text = reply[row].username
            cell.content.text = reply[row].content
            
            return cell
        }
    }
}
