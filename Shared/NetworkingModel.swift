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
    
    private let baseAPI = "http://www.bilibilicd.tk/api"
    
    private func generateAPI(byType type: CoverType, andNID nid: Int? = nil) -> URL? {
        var api = baseAPI
        
        if type == .hotList {
            return URL(string: api + "/hot_list")
        } else {
            api += "/search?type="
            switch type {
            case .video: api += "av"
            case .article: api += "cv"
            case .live: api += "lv"
            default: return nil
            }
        }
        
        api += "&nid=\(nid!)"
        
        return URL(string: api)
    }
    
    open func getCoverInfo(byType type: CoverType, andNID nid: UInt64) {
        guard let url = generateAPI(byType: type, andNID: Int(nid)) else {
            fatalError("cannot generate api url")
        }
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil,
                let content = data,
                let newInfo = try? JSONDecoder().decode(Info.self, from: content)
                else {
                    print(data!)
                    self.videoDelegate { $0.connectError() }
                    return
            }
            if newInfo.isValid {
                self.videoDelegate { $0.gotVideoInfo(newInfo) }
                self.getImage(fromUrlPath: newInfo.imageURL)
            } else {
                self.getInfoFromBilibili(forAV: nid, onFailure: {
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
