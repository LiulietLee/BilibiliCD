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

class NetworkingModel {
    
    weak var delegateForVideo: VideoCoverDelegate?
    weak var delegateForUpuser: UpuserImgDelegate?
    let session = URLSession.shared
    
    private let production = true
    private var baseAPI: String {
        if production {
            return "http://45.32.54.201/api"
        } else {
            return "http://127.0.0.1:8000/api"
        }
    }
    
    private func updateServerRecord(type: CoverType, nid: UInt64, info: Info) {
        guard let url = generateAPI(byType: type, andNID: Int(nid), andInfo: info) else {
            fatalError("cannot generate api url")
        }

        let parameters: [String : Any] = ["type": CoverType.stringType(type: type)!, "nid": nid, "url": info.imageURL, "title": info.title, "author": info.author]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
    }
    
    private func generateAPI(byType type: CoverType, andNID nid: Int? = nil, andInfo newInfo: Info? = nil) -> URL? {
        var api = baseAPI
        
        if type == .hotList {
            return URL(string: api + "/hot_list")
        } else {
            api += "/db"
            if newInfo != nil {
                api += "/update"
                return URL(string: api)
            } else {
                api += "/search?type="
            }
            
            switch type {
            case .video: api += "av"
            case .article: api += "cv"
            case .live: api += "lv"
            default: return nil
            }

            api += "&nid=\(nid!)"
        }
        
        return URL(string: api)
    }
    
    private func fetchCoverRecordFromServer(withType type: CoverType, andID nid: UInt64) {
        guard let url = generateAPI(byType: type, andNID: Int(nid)) else {
            fatalError("cannot generate api url")
        }
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil,
                let content = data,
                let newInfo = try? JSONDecoder().decode(Info.self, from: content)
                else {
                    self.videoDelegate { $0.cannotFindVideo() }
                    return
            }
            if newInfo.isValid {
                self.videoDelegate { $0.gotVideoInfo(newInfo) }
                self.getImage(fromUrlPath: newInfo.imageURL)
            } else {
                self.videoDelegate { $0.cannotFindVideo() }
            }
        }
        task.resume()
    }
    
    open func getCoverInfo(byType type: CoverType, andNID nid: UInt64) {
        switch type {
        case .video:   getInfo(forAV: nid)
        case .article: getInfo(forCV: nid)
        case .live:    getInfo(forLV: nid)
        default: break
        }
    }
    
    private func getInfo(forAV: UInt64) {
        BKVideo(av: Int(forAV)).getInfo {
            guard let info = $0 else {
                self.fetchCoverRecordFromServer(withType: .video, andID: forAV)
                return
            }
            let url = info.coverImageURL.absoluteString
            let newInfo = Info(author: info.author, title: info.title, imageURL: url)
            self.videoDelegate { $0.gotVideoInfo(newInfo) }
            self.getImage(fromUrlPath: url)
            self.updateServerRecord(type: .video, nid: forAV, info: newInfo)
        }
    }
    
    private func getInfo(forCV: UInt64) {
        BKArticle(cv: Int(forCV)).getInfo {
            guard let info = $0 else {
                self.fetchCoverRecordFromServer(withType: .article, andID: forCV)
                return
            }
            let url = info.coverImageURL.absoluteString
            let newInfo = Info(author: info.author, title: info.title, imageURL: url)
            self.videoDelegate { $0.gotVideoInfo(newInfo) }
            self.getImage(fromUrlPath: url)
            self.updateServerRecord(type: .article, nid: forCV, info: newInfo)
        }
    }
    
    private func getInfo(forLV: UInt64) {
        BKLiveRoom(Int(forLV)).getInfo {
            guard let info = $0 else {
                self.fetchCoverRecordFromServer(withType: .live, andID: forLV)
                return
            }
            let url = info.coverImageURL.absoluteString
            let newInfo = Info(author: String(info.mid), title: info.title, imageURL: url)
            self.videoDelegate { $0.gotVideoInfo(newInfo) }
            self.getImage(fromUrlPath: url)
            self.updateServerRecord(type: .live, nid: forLV, info: newInfo)
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
