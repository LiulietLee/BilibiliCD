//
//  ReplyController.swift
//  BCD
//
//  Created by Liuliet.Lee on 15/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit
import LLDialog

class ReplyController: UIViewController, UITableViewDataSource, UITableViewDelegate, EditControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newReplyButton: UIButton!
    private var refreshControl = UIRefreshControl()
    
    private var provider = CommentProvider.shared
    private var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        newReplyButton.layer.masksToBounds = true
        newReplyButton.layer.cornerRadius = 28.0

        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        load()
    }
    
    @objc private func reload() {
        provider.resetReplyParam()
        load()
    }
    
    private func load() {
        if isLoading { return }
        isLoading = true
        provider.getNextReplyList() { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
                self.isLoading = false
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return provider.currentComment == nil ? 0 : provider.replies.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! CommentCell
            
            cell.data = provider.currentComment
            cell.liked = provider.buttonStatus[provider.currentCommentIndex].liked
            cell.disliked = provider.buttonStatus[provider.currentCommentIndex].disliked
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reply", for: indexPath) as! ReplyCell
            
            cell.data = provider.replies[indexPath.row - 1]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = provider.replies.count
        if indexPath.row == count - 1, count < provider.replyCount {
            load()
        }
    }
    
    func editFinished(username: String, content: String) {
        provider.newReply(username: username, content: content) { [weak self] (reply) in
            guard let self = self else { return }
            if reply == nil {
                DispatchQueue.main.async { [weak self] in
                    guard self != nil else { return }
                    LLDialog()
                        .set(title: "咦")
                        .set(title: "哪里出了问题……")
                        .show()
                }
            } else {
                self.reload()
            }
        }
    }
    
    @IBAction func dislikeButtonTapped() {
        provider.dislikeComment(commentIndex: provider.currentCommentIndex) { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        }
    }
    
    @IBAction func likeButtonTapped() {
        provider.likeComment(commentIndex: provider.currentCommentIndex) { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditController {
            vc.delegate = self
            vc.model = .reply
        }
    }
}
