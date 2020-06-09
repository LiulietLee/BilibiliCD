//
//  CommentProvider.swift
//  BCD
//
//  Created by Liuliet.Lee on 6/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation

class CommentProvider: AbstractProvider {
    
    public static var shared = CommentProvider()
    
    public private(set) var comments = [Comment]()
    public private(set) var buttonStatus = [(liked: Bool, disliked: Bool)]()
    public private(set) var replies = [Reply]()
    
    public private(set) var commentCount = 0
    public private(set) var replyCount = 0
    public var currentCommentIndex = 0 {
        willSet {
            if newValue != currentCommentIndex {
                resetReplyParam()
            }
        }
    }
    public var currentComment: Comment? {
        get {
            return currentCommentIndex < comments.count
                ? comments[currentCommentIndex]
                : nil
        }
    }
    private var commentPage = 0
    private var replyPage = 0
    private var countLimit = 20
    
    public func resetReplyParam() {
        replies = []
        replyCount = 0
        replyPage = 0
    }
    
    public func resetCommentParam() {
        comments = []
        buttonStatus = []
        commentCount = 0
        commentPage = 0
        currentCommentIndex = 0
    }
    
    public func resetParam() {
        resetCommentParam()
        resetReplyParam()
    }
    
    public func getNextCommentList(reset: Bool = false, completion: @escaping () -> Void) {
        if commentPage > 100 { return }
        
        if reset {
            commentPage = 0
            currentCommentIndex = 0
        }
        
        guard let url = APIFactory.getCommentListAPI(withCommentPage: commentPage, andCount: countLimit, env: env) else {
            completion()
            return
        }
        
        session.dataTask(with: url) { (data, response, error) in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            if error == nil,
                let content = data,
                let result = try? decoder.decode(ListResponse<Comment>.self, from: content) {
                self.commentPage += 1
                self.commentCount = result.count
                
                if reset {
                    self.comments = result.data
                } else {
                    self.comments.append(contentsOf: result.data)
                }

                while self.buttonStatus.count < self.comments.count {
                    self.buttonStatus.append((false, false))
                }
            }
            
            completion()
        }.resume()
    }
    
    public func getNextReplyList(reset: Bool = false, completion: @escaping () -> Void) {
        if replyPage > 100 { return }
        
        if reset {
            replyPage = 0
        }
        
        guard let url = APIFactory.getReplyListAPI(withCommentID: comments[currentCommentIndex].id, andPage: replyPage, andCount: countLimit, env: env) else {
            return
        }
        
        session.dataTask(with: url) { (data, response, error) in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if error == nil,
                let content = data,
                let result = try? decoder.decode(ListResponse<Reply>.self, from: content) {
                self.replyPage += 1
                self.replyCount = result.count

                if reset {
                    self.replies = result.data
                } else {
                    self.replies.append(contentsOf: result.data)
                }
            }
            
            completion()
        }.resume()
    }
    
    public func newComment(username: String, content: String, completion: @escaping (Comment?) -> Void) {
        guard let url = APIFactory.getNewCommentAPI(env: env) else {
            completion(nil)
            return
        }
        sendDataToServer(Comment.self, url: url, username: username, content: content) { (response) in
            completion(response?.data)
        }
    }
    
    public func newReply(username: String, content: String, completion: @escaping (Reply?) -> Void) {
        guard let url = APIFactory.getNewReplyAPI(withCommentID: currentComment!.id, env: env) else {
            completion(nil)
            return
        }
        sendDataToServer(Reply.self, url: url, username: username, content: content) { (response) in
            self.comments[self.currentCommentIndex].replyCount += 1
            completion(response?.data)
        }
    }
    
    public func likeComment(commentIndex i: Int, completion: @escaping () -> Void) {
        buttonStatus[i].liked = !buttonStatus[i].liked
        let liked = buttonStatus[i].liked
        comments[i].suki += liked ? 1 : -1
        guard let url = APIFactory
            .getLikeCommentAPI(withCommentID: comments[i].id, cancel: !liked, env: env)
            else { return }
        session.dataTask(with: url) { (_, _, _) in
            completion()
        }.resume()
    }
    
    public func dislikeComment(commentIndex i: Int, completion: @escaping () -> Void) {
        buttonStatus[i].disliked = !buttonStatus[i].disliked
        let disliked = buttonStatus[i].disliked
        comments[i].kirai += disliked ? 1 : -1
        guard let url = APIFactory
            .getDislikeCommentAPI(withCommentID: comments[i].id, cancel: !disliked, env: env)
            else { return }
        session.dataTask(with: url) { (_, _, _) in
            completion()
        }.resume()
    }
}

extension CommentProvider {
    private func sendDataToServer<T: Decodable>(_ type: T.Type, url: URL, username: String, content: String, _ completion: @escaping (MessageResponse<T>?) -> Void) {
        let parameters: [String : Any] = ["username": username, "content": content]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        session.dataTask(with: request) { data, response, error in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if error == nil,
                let content = data,
                let result = try? decoder.decode(MessageResponse<T>.self, from: content) {
                completion(result)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
