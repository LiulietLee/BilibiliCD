//
//  NetworkingModel.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

protocol VideoCoverDelegate {
    func gotVideoInfo(info: Info)
    func gotImage(image: UIImage)
    func connectError()
    func cannotFindVideo()
}

protocol UpuserImgDelegate {
    func gotUpusers(ups: [Upuser])
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
    
    var delegateForVideo: VideoCoverDelegate?
    var delegateForUpuser: UpuserImgDelegate?
    let session = URLSession.shared
    
    open func getInfoFromAvNumber(avNum: Int) {
        var newInfo: Info?
        
        let path = "http://bilibilicd.tk/video/ios/" + String(avNum) + "/"
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                print(err)
                if let del = self.delegateForVideo {
                    del.connectError()
                }
            } else {
                DispatchQueue.main.async {
                    if let content = data {
                        do {
                            let jsonData = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                            
                            newInfo?.author = jsonData["author"] as? String ?? "Can't get author"
                            newInfo?.title = jsonData["title"] as? String ?? "Can't get title"
                            newInfo?.imageUrl = jsonData["url"] as? String ?? "Can't get url of cover"
                            
                            if let del = self.delegateForVideo {
                                if newInfo!.imageUrl == "error" {
                                    del.cannotFindVideo()
                                } else {
                                    del.gotVideoInfo(info: newInfo!)
                                    self.getImageFromImageUrlPath(path: newInfo!.imageUrl!)
                                }
                            }
                        } catch {
                            print("serialize error")
                            if let del = self.delegateForVideo {
                                del.connectError()
                            }
                        }
                    } else {
                        if let del = self.delegateForVideo {
                            del.connectError()
                        }
                    }
                }
            }
        }
        
        newInfo = Info()
        task.resume()
    }
    
    open func getUpuserFrom(searchText: String) {
        var upusers = [Upuser]()
        var sum = 0
        
        let userName = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let path = "http://bilibilicd.tk/ios/upuser-keyword=" + userName
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let tesk = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                print(err)
                if let del = self.delegateForUpuser {
                    del.connectError()
                }
            } else {
                if let content = data {
                    DispatchQueue.main.async {
                        do {
                            let jsonData = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                            
                            sum = jsonData["sum"] as? Int ?? 0
                            
                            if sum == 0 {
                                if let del = self.delegateForUpuser {
                                    del.cannotGetUser()
                                    return
                                }
                            }
                            
                            if let users = jsonData["upusers"] as? [AnyObject] {
                                for user in users {
                                    let name = user["name"] as? String ?? ""
                                    let video = user["videonum"] as? String ?? ""
                                    let fans = user["fansnum"] as? String ?? ""
                                    let img = user["imgurl"] as? String ?? ""
                                    let newUser = Upuser(name: name, videoNum: video, fansNum: fans, imgUrl: img)
                                    upusers.append(newUser)
                                }
                            }
                            
                            if let del = self.delegateForUpuser {
                                del.gotUpusers(ups: upusers)
                            }
                        } catch {
                            if let del = self.delegateForUpuser {
                                del.connectError()
                            }
                        }
                    }
                }
            }
        }
        tesk.resume()
    }
    
    private func getImageFromImageUrlPath(path: String) {
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                print(err)
                if let del = self.delegateForVideo {
                    del.connectError()
                }
            } else {
                if let content = data {
                    DispatchQueue.main.async {
                        if let img = UIImage(data: content) {
                            if let del = self.delegateForVideo {
                                del.gotImage(image: img)
                            }
                        }
                    }
                } else {
                    if let del = self.delegateForVideo {
                        del.connectError()
                    }
                }
            }
        }
        task.resume()
    }
}
