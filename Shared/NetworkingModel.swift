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
    func gotImage(_ image: Image)
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

/// TODO: - 以后需要重构网络层
class NetworkingModel {
    
    weak var delegateForVideo: VideoCoverDelegate?
    weak var delegateForUpuser: UpuserImgDelegate?
    let session = URLSession.shared
    
    private let baseAPI = "http://bilibilicd.tk/api"
    
    private func generateAPI(byType type: CoverType, andNID nid: Int? = nil) -> URL? {
        var api = baseAPI
        
        if type == .hotList {
            // todo
        } else {
            api += "/search?type="
            switch type {
            case .video: api += "av"
            case .article: api += "cv"
            default: return nil
            }
        }
        
        api += "&nid=\(nid!)"
        
        return URL(string: api)
    }
    
    open func getCoverInfo(byType type: CoverType, andNID nid: Int) {
        guard let url = generateAPI(byType: type, andNID: nid) else {
            fatalError("cannot generate api url")
        }
        let request = URLRequest(url: url)
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
        guard let url = generateAPI(byType: .article, andNID: Int(cvNum)) else {
            fatalError("cannot generate api url")
        }
        let request = URLRequest(url: url)
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
        guard let url = generateAPI(byType: .video, andNID: Int(avNum)) else {
            fatalError("cannot generate api url")
        }
        let request = URLRequest(url: url)
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
    
    private func getImage(fromUrlPath path: String) {
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { data, response, error in
            if let content = data {
                if path.isGIF {
                    if let gif = UIImage.gif(data: content) {
                        self.videoDelegate { $0.gotImage(.gif(gif, data: content)) }
                    } else {
                        self.videoDelegate { $0.connectError() }
                    }
                } else {
                    if let img = UIImage(data: content) {
                        self.videoDelegate { $0.gotImage(.normal(img)) }
                    } else {
                        self.videoDelegate { $0.connectError() }
                    }
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
