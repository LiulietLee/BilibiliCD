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
    
    open func getLiveInfo(lvNum: UInt64) {
        let path = "https://api.live.bilibili.com/AppRoom/index?device=phone&platform=ios&scale=3&build=10000&room_id=\(lvNum)"
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { data, response, error in
            if let content = data {
                do {
                    struct InfoWrapper: Decodable {
                        let data: Info
                    }
                    let jsonData = try JSONDecoder().decode(InfoWrapper.self, from: content)
                    let newInfo = jsonData.data

                    if newInfo.isValid {
                        self.videoDelegate { $0.gotVideoInfo(newInfo) }
                        self.getImage(fromUrlPath: newInfo.imageURL)
                    } else {
                        self.videoDelegate { $0.cannotFindVideo() }
                    }
                } catch {
                    print("serialize error")
                    self.videoDelegate{ $0.connectError() }
                }
            } else {
                print(error ?? "network error")
                self.videoDelegate { $0.connectError() }
            }
        }
        
        task.resume()
    }
    
    open func getArticleInfo(cvNum: UInt64) {
        let path = "http://bilibilicd.tk/ios/article/\(cvNum)/"
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let content = data {
                do {
                    let newInfo = try JSONDecoder().decode(Info.self, from: content)
                    if newInfo.isValid {
                        self.videoDelegate { $0.gotVideoInfo(newInfo) }
                        self.getImage(fromUrlPath: newInfo.imageURL)
                    } else {
                        self.videoDelegate { $0.cannotFindVideo() }
                    }
                } catch {
                    print("serialize error")
                    self.videoDelegate { $0.connectError() }
                }
            } else {
                print(error ?? "network error")
                self.videoDelegate { $0.connectError() }
            }
        }
        
        task.resume()
    }
    
    open func getInfoFromAvNumber(avNum: UInt64) {
        let path = "http://bilibilicd.tk/video/ios/\(avNum)/"
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil, let content = data
                , let newInfo = try? JSONDecoder().decode(Info.self, from: content)
                else {
                    return self.getInfoFromBilibili(forAV: avNum, onFailure: {
                        self.videoDelegate { $0.connectError() }
                    })
            }
            if newInfo.isValid {
                self.videoDelegate { $0.gotVideoInfo(newInfo) }
                self.getImage(fromUrlPath: newInfo.imageURL)
            } else {
                self.getInfoFromBilibili(forAV: avNum, onFailure: {
                    self.videoDelegate { $0.cannotFindVideo() }
                })
            }
        }
        task.resume()
    }
    
    private func getInfoFromBilibili(forAV: UInt64, onFailure: @escaping () -> Void) {
        BKVideo(av: Int(forAV)).getInfo {
            guard let info = $0 else { return onFailure() }
            let url = info.coverImageURL.absoluteString
            let newInfo = Info(author: info.author, title: info.title, imageURL: url)
            self.videoDelegate { $0.gotVideoInfo(newInfo) }
            self.getImage(fromUrlPath: url)
        }
    }
    
    open func getUpuser(keyword searchText: String) {
        let userName = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let path = "http://bilibilicd.tk/ios/upuser-keyword=\(userName)"
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let tesk = session.dataTask(with: request) { data, response, error in
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
            } else {
                print(error ?? "network error")
                // TODO: Check if this needs to be on main thread.
                self.delegateForUpuser?.connectError()
            }
        }
        tesk.resume()
    }
    
    open func sendScaleData(type: String, size: CGSize, time: Double) {
        let stringUrl = "http://www.bilibilicd.tk/ios/waifu2x/?iphone=\(type)&time=\(time)&len=\(size.height)&wid=\(size.width)"
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        let task = session.dataTask(with: url) { data, response, error in
            if let content = data {
                struct statusWrapper: Decodable {
                    let status: String
                }
                let json = try? JSONDecoder().decode(statusWrapper.self, from: content)
                print(json?.status ?? "data error")
            } else {
                print(error ?? "unknown error")
            }
        }
        task.resume()
    }
    
    private func getImage(fromUrlPath path: String) {
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { data, response, error in
            if let content = data {
                let img: UIImage?
                if path.hasSuffix("gif") {
                    img = UIImage.gif(data: content)
                } else {
                    img = UIImage(data: content)
                }
                if img != nil {
                    self.videoDelegate { $0.gotImage(img!) }
                }
            } else {
                print(error ?? "network error")
                self.videoDelegate { $0.connectError() }
            }
        }
        task.resume()
    }

    private func videoDelegate(_ perform: @escaping (VideoCoverDelegate) -> Void) {
        DispatchQueue.main.async {
            if let delegate = self.delegateForVideo {
                perform(delegate)
            }
        }
    }
}
