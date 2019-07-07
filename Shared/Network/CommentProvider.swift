//
//  CommentProvider.swift
//  BCD
//
//  Created by Liuliet.Lee on 6/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation

class CommentProvider: AbstractProvider {
    
    public func getComments(page: Int, count: Int = 20, completion: @escaping ([Comment]?) -> Void) {
        guard let url = APIFactory.getAPI(withCommentPage: page, andCount: count) else {
            completion(nil)
            return
        }
        session.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            if error == nil,
                let content = data,
                let list = try? JSONDecoder().decode([Comment].self, from: content) {
                completion(list)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
