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

struct Upuser: Decodable {
    var name: String
    var videoNum: String
    var fansNum: String
    var imgURL: String
    enum CodingKeys: String, CodingKey {
        case name
        case videoNum = "videonum"
        case fansNum = "fansnum"
        case imgURL = "imgurl"
    }
}

class NetworkingModel {
    
    weak var delegateForVideo: VideoCoverDelegate?
    weak var delegateForUpuser: UpuserImgDelegate?
    let session = URLSession.shared
    
    open func getLiveInfo(lvNum: Int) {
        let path = "https://api.live.bilibili.com/AppRoom/index?device=phone&platform=ios&scale=3&build=10000&room_id=\(lvNum)"
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                print(err)
            } else {
                DispatchQueue.main.async {
                    if let content = data {
                        do {
                            struct InfoWrapper: Decodable {
                                let data: Info
                            }
                            let jsonData = try JSONDecoder().decode(InfoWrapper.self, from: content)
                            let newInfo = jsonData.data
                            
                            if let del = self.delegateForVideo {
                                if newInfo.imageURL != "error" {
                                    del.gotVideoInfo(newInfo)
                                    self.getImage(fromUrlPath: newInfo.imageURL)
                                } else {
                                    del.cannotFindVideo()
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
                            let newInfo = try JSONDecoder().decode(Info.self, from: content)
                            
                            if let del = self.delegateForVideo {
                                if newInfo.imageURL == "error" {
                                    del.cannotFindVideo()
                                } else {
                                    del.gotVideoInfo(newInfo)
                                    self.getImage(fromUrlPath: newInfo.imageURL)
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
                            struct UpuserWrapper: Decodable {
                                let sum: Int
                                let upusers: [Upuser]
                            }
                            
                            let jsonData = try JSONDecoder().decode(UpuserWrapper.self, from: content)
                            
                            if jsonData.sum > 0 && jsonData.upusers.count > 0 {
                                self.delegateForUpuser?.gotUpusers(jsonData.upusers)
                            } else {
                                self.delegateForUpuser?.cannotGetUser()
                            }
                            
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
