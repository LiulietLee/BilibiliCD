//
//  FeedbackController.swift
//  BCD
//
//  Created by Liuliet.Lee on 11/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit
import LLDialog

class FeedbackController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newCommentButton: UIButton!
    private var refreshControl = UIRefreshControl()

    private var isLoading = false
    private let commentProvider = CommentProvider.shared
    
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
        
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc private func reload() {
        commentProvider.resetParam()
        load()
    }
    
    private func load() {
        if isLoading { return }
        isLoading = true
        commentProvider.getNextCommentList() { [weak self] in
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
        return commentProvider.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
        
        let idx = indexPath.row
        cell.data = commentProvider.comments[idx]
        cell.liked = commentProvider.buttonStatus[idx].liked
        cell.disliked = commentProvider.buttonStatus[idx].disliked
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = commentProvider.comments.count
        if indexPath.row == count - 1, count < commentProvider.commentCount {
            load()
        }
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        if let superView = sender.superview,
            let cell = superView.superview as? CommentCell,
            let index = tableView.indexPath(for: cell) {
            commentProvider.likeComment(commentIndex: index.row) { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.tableView.reloadRows(at: [index], with: .none)
                }
            }
        }
    }
    
    @IBAction func dislikeButtonTapped(_ sender: UIButton) {
        if let superView = sender.superview,
            let cell = superView.superview as? CommentCell,
            let index = tableView.indexPath(for: cell) {
            commentProvider.dislikeComment(commentIndex: index.row) { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.tableView.reloadRows(at: [index], with: .none)
                }
            }
        }
    }
    
    @IBAction func helpButtonTapped(_ sender: UIBarButtonItem) {
        // TODO
    }
    
    func editFinished(username: String, content: String) {
        commentProvider.newComment(username: username, content: content) { [weak self] (comment) in
            guard let self = self else { return }
            if comment == nil {
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
    
    @IBAction func showHelp(_ sender: UIBarButtonItem) {
        let vc = HisTutViewController()
        vc.page = "AboutFeedback"
        present(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if segue.destination is ReplyController,
            let cell = sender as? UITableViewCell,
            let index = tableView.indexPath(for: cell),
            commentProvider.comments.count > index.row {
            commentProvider.currentCommentIndex = index.row
        } else if let vc = segue.destination as? EditController {
            vc.delegate = self
            vc.model = .comment
        }
    }
    
}
