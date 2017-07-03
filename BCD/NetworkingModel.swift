//
//  NetworkingModel.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

protocol NetworkingDelegate {
    func gotVideoInfo(info: Info)
    func gotImage(image: UIImage)
    func connectError()
}

class NetworkingModel {
    
    var delegate: NetworkingDelegate?
    let session = URLSession.shared
    
    open func getInfoFromAvNumber(avNum: Int) {
        var newInfo: Info?
        
        let path = "https://www.bilibili.com/video/av" + String(avNum)
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                print(err)
                if let del = self.delegate {
                    del.connectError()
                }
            } else {
                if let content = data {
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        newInfo?.author = jsonData["author"] as? String ?? "Can't get author"
                        newInfo?.title = jsonData["title"] as? String ?? "Can't get title"
                        newInfo?.imageUrl = jsonData["url"] as? String ?? "Can't get url of cover"
                        
                        if let del = self.delegate {
                            del.gotVideoInfo(info: newInfo!)
                        }
                    } catch {
                        print("serialize error")
                        if let del = self.delegate {
                            del.connectError()
                            self.getImageFromImageUrlPath(path: newInfo!.imageUrl!)
                        }
                    }
                } else {
                    if let del = self.delegate {
                        del.connectError()
                    }
                }
            }
        }
        
        newInfo = Info()
        task.resume()
    }
    
    private func getImageFromImageUrlPath(path: String) {
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                print(err)
                if let del = self.delegate {
                    del.connectError()
                }
            } else {
                if let content = data {
                    if let img = UIImage(data: content) {
                        if let del = self.delegate {
                            del.gotImage(image: img)
                        }
                    }
                }
            }
        }
        task.resume()
    }
}
