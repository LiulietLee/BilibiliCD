//
//  ReplyController.swift
//  BCD
//
//  Created by Liuliet.Lee on 15/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit

protocol ReplyControllerDelegate: class {
    func getBackFromReplyController(comment: Comment, liked: Bool, disliked: Bool)
}

class ReplyController: UIViewController, UITableViewDataSource, UITableViewDelegate, EditControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newReplyButton: UIButton!
    
    private var reply = [Reply]()
    private var commentProvider = CommentProvider()
    var comment: Comment!
    var liked = false, disliked = false
    weak var delegate: ReplyControllerDelegate? = nil
    
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

        commentProvider.getNextReplyList(comment: comment!) { [weak self] (data) in
            guard let self = self, let list = data else { return }
            self.reply = list
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.getBackFromReplyController(comment: comment, liked: liked, disliked: disliked)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reply.count + (comment == nil ? 0 : 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! CommentCell
            
            cell.data = comment!
            cell.liked = liked
            cell.disliked = disliked
            
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
    
    @IBAction func dislikeButtonTapped() {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CommentCell {
            liked = !liked
            comment.suki += liked ? 1 : -1
            cell.liked = liked
            cell.data = comment
        }
    }
    
    @IBAction func likeButtonTapped() {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CommentCell {
            disliked = !disliked
            comment.kirai += disliked ? 1 : -1
            cell.disliked = disliked
            cell.data = comment
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditController {
            vc.delegate = self
            vc.model = .reply
            vc.currentComment = comment
        }
    }
}
