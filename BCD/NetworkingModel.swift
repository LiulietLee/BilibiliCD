//
//  NetworkingModel.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

protocol VideoCoverDelegate: class {
    func gotVideoInfo(_ info: Info)
    func gotImage(_ image: UIImage)
    func connectError()
    func cannotFindVideo()
}

protocol UpuserImgDelegate: class {
    func gotUpusers(_ ups: [Upuser])
    func connectError()
    func cannotGetUser()
}

struct Upuser {
    var name: String
    var videoNum: String
    var fansNum: String
    var imgUrl: String
}

class NetworkingModel {
    
    weak var delegateForVideo: VideoCoverDelegate?
    weak var delegateForUpuser: UpuserImgDelegate?
    let session = URLSession.shared
    
    open func getInfoFromAvNumber(avNum: Int) {
        let path = "http://bilibilicd.tk/video/ios/\(avNum)/"
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                print(err)
                self.delegateForVideo?.connectError()
            } else {
                DispatchQueue.main.async {
                    if let content = data {
                        do {
                            let jsonData = try JSONSerialization.jsonObject(with: content, options: .mutableContainers) as AnyObject

                            let newInfo = Info()
                            newInfo.author = jsonData["author"] as? String ?? "Can't get author"
                            newInfo.title = jsonData["title"] as? String ?? "Can't get title"
                            newInfo.imageUrl = jsonData["url"] as? String ?? "Can't get url of cover"
                            
                            if let del = self.delegateForVideo {
                                if newInfo.imageUrl == "error" {
                                    del.cannotFindVideo()
                                } else {
                                    del.gotVideoInfo(newInfo)
                                    self.getImage(fromUrlPath: newInfo.imageUrl!)
                                }
                            }
                        } catch {
                            print("serialize error")
                            self.delegateForVideo?.connectError()
                        }
                    } else {
                        self.delegateForVideo?.connectError()
                    }
                }
            }
        }

        task.resume()
    }
    
    open func getUpuser(keyword searchText: String) {
        let userName = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let path = "http://bilibilicd.tk/ios/upuser-keyword=\(userName)"
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let tesk = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                print(err)
                self.delegateForUpuser?.connectError()
            } else {
                if let content = data {
                    DispatchQueue.main.async {
                        do {
                            let jsonData = try JSONSerialization.jsonObject(with: content, options: .mutableContainers) as AnyObject

                            guard let sum = jsonData["sum"] as? Int, sum > 0,
                                let users = jsonData["upusers"] as? [AnyObject]
                                else {
                                    self.delegateForUpuser?.cannotGetUser()
                                    return
                            }

                            let upusers = users.map { user in
                                return Upuser(name: user["name"] as? String ?? "",
                                              videoNum: user["videonum"] as? String ?? "",
                                              fansNum: user["fansnum"] as? String ?? "",
                                              imgUrl: user["imgurl"] as? String ?? "")
                            }

                            self.delegateForUpuser?.gotUpusers(upusers)
                        } catch {
                            self.delegateForUpuser?.connectError()
                        }
                    }
                }
            }
        }
        tesk.resume()
    }
    
    private func getImage(fromUrlPath path: String) {
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                print(err)
                self.delegateForVideo?.connectError()
            } else {
                if let content = data {
                    DispatchQueue.main.async {
                        if let img = UIImage(data: content) {
                            self.delegateForVideo?.gotImage(img)
                        }
                    }
                } else {
                    self.delegateForVideo?.connectError()
                }
            }
        }
        task.resume()
    }
}
