//
//  AssetProvider.swift
//  BCD
//
//  Created by Liuliet.Lee on 27/9/2018.
//  Copyright © 2018 Liuliet.Lee. All rights reserved.
//

import UIKit

class AssetProvider: AbstractProvider {
    
    open func getImage(fromUrlPath path: String, completion: @escaping (Image?) -> Void) {
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { data, response, error in
            if let content = data {
                if path.isGIF {
                    if let gif = UIImage.gif(data: content) {
                        completion(Image.gif(gif, data: content))
                    } else {
                        completion(nil)
                    }
                } else {
                    if let img = UIImage(data: content) {
                        completion(Image.normal(img))
                    } else {
                        completion(nil)
                    }
                }
            } else {
                print(error ?? "network error")
                completion(nil)
            }
        }
        task.resume()
    }
    
}
