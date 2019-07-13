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
        guard let url = APIFactory.getAPI(withCommentPage: page, andCount: count, env: env) else {
            completion(nil)
            return
        }
        session.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if error == nil,
                let content = data,
                let list = try? decoder.decode([Comment].self, from: content) {
                completion(list)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
