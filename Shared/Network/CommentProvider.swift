//
//  CommentProvider.swift
//  BCD
//
//  Created by Liuliet.Lee on 6/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation

class CommentProvider: AbstractProvider {
    
    private var commentPage = 0
    private var replyPage = 0
    private var countLimit = 20
    
    public func getNextCommentList(completion: @escaping ([Comment]?) -> Void) {
        guard let url = APIFactory.getCommentListAPI(withCommentPage: commentPage, andCount: countLimit, env: env) else {
            completion(nil)
            return
        }
        
        session.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if error == nil,
                let content = data,
                let list = try? decoder.decode([Comment].self, from: content) {
                self.commentPage += 1
                completion(list)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    public func getNextReplyList(comment: Comment, completion: @escaping ([Reply]?) -> Void) {
        guard let url = APIFactory.getReplyListAPI(withCommentID: comment.id, andPage: replyPage, andCount: countLimit, env: env) else {
            completion(nil)
            return
        }
        
        session.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if error == nil,
                let content = data,
                let list = try? decoder.decode([Reply].self, from: content) {
                completion(list)
                self.replyPage += 1
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    private func sendDataToServer(url: URL, username: String, content: String, _ completion: @escaping (Int?) -> Void) {
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
            guard let data = data, error == nil else {
                print("\(String(describing: error))")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")

            if let httpStatus = response as? HTTPURLResponse {
                completion(httpStatus.statusCode)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    public func newComment(username: String, content: String, completion: @escaping (Int?) -> Void) {
        guard let url = APIFactory.getNewCommentAPI(env: env) else {
            completion(nil)
            return
        }
        sendDataToServer(url: url, username: username, content: content, completion)
    }
    
    public func newReply(commentID: Int, username: String, content: String, completion: @escaping (Int?) -> Void) {
        guard let url = APIFactory.getNewReplyAPI(withCommentID: commentID, env: env) else {
            completion(nil)
            return
        }
        sendDataToServer(url: url, username: username, content: content, completion)
    }
    
    public func likeComment(commentID: Int, cancel: Bool) {
        guard let url = APIFactory.getLikeCommentAPI(withCommentID: commentID, cancel: cancel, env: env) else {
            return
        }
        session.dataTask(with: URLRequest(url: url)).resume()
    }
    
    public func dislikeComment(commentID: Int, cancel: Bool) {
        guard let url = APIFactory.getDislikeCommentAPI(withCommentID: commentID, cancel: cancel, env: env) else {
            return
        }
        session.dataTask(with: URLRequest(url: url)).resume()
    }
}
