//
//  FeedbackController.swift
//  BCD
//
//  Created by Liuliet.Lee on 11/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit

class FeedbackController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditControllerDelegate, ReplyControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newCommentButton: UIButton!
    
    private var isLoading = false
    private var stopLoading = false
    private var comments = [Comment]()
    private var buttonStatus: [(liked: Bool, disliked: Bool)] = []
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
        
        load()
    }
    
    private func load() {
        if isLoading || stopLoading { return }
        isLoading = true
        commentProvider.getNextCommentList() { [weak self] (data) in
            guard let self = self, let list = data else { return }
            if list.isEmpty {
                self.stopLoading = true
                return
            }
            self.comments.append(contentsOf: list)
            while self.buttonStatus.count < self.comments.count {
                self.buttonStatus.append((false, false))
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
                self.isLoading = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
        
        let idx = indexPath.row
        cell.data = comments[idx]
        cell.liked = buttonStatus[idx].liked
        cell.disliked = buttonStatus[idx].disliked
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = comments.count
        if indexPath.row == count - 1 {
            load()
        }
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        if let superView = sender.superview,
            let cell = superView.superview as? CommentCell,
            let index = tableView.indexPath(for: cell) {
            buttonStatus[index.row].liked = !buttonStatus[index.row].liked
            let liked = buttonStatus[index.row].liked
            comments[index.row].suki += liked ? 1 : -1
            cell.data = comments[index.row]
            cell.liked = liked
            commentProvider.likeComment(commentID: comments[index.row].id, cancel: !liked)
        }
    }
    
    @IBAction func dislikeButtonTapped(_ sender: UIButton) {
        if let superView = sender.superview,
            let cell = superView.superview as? CommentCell,
            let index = tableView.indexPath(for: cell) {
            buttonStatus[index.row].disliked = !buttonStatus[index.row].disliked
            let disliked = buttonStatus[index.row].disliked
            comments[index.row].kirai += disliked ? 1 : -1
            cell.data = comments[index.row]
            cell.disliked = disliked
            commentProvider.dislikeComment(commentID: comments[index.row].id, cancel: !disliked)
        }
    }
    
    func getBackFromReplyController(comment: Comment, liked: Bool, disliked: Bool) {
        // TODO
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
            (vc.liked, vc.disliked) = buttonStatus[index.row]
        } else if let vc = segue.destination as? EditController {
            vc.delegate = self
            vc.model = .comment
        }
    }
    
}
