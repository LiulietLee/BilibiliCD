//
//  HotListProvider.swift
//  BCD
//
//  Created by Liuliet.Lee on 27/9/2018.
//  Copyright © 2018 Liuliet.Lee. All rights reserved.
//

import Foundation

class HotListProvider: AbstractProvider {
    
    open func getHotList(completion: @escaping ([Info]?) -> Void) {
        guard let url = APIFactory.getCoverAPI(byType: .hotList) else {
            completion(nil)
            return
        }
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil,
                let content = data,
                let list = try? JSONDecoder().decode([Info].self, from: content) {
                completion(list)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
