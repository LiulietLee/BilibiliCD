//
//  CoverInfoProvider.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class CoverInfoProvider: AbstractProvider {
    
    open func getCoverInfoBy(
        type: CoverType,
        andStringID id: UInt64,
        completion: @escaping (Info?) -> Void
    ) {
        switch type {
        case .video:   getInfo(forAV: id, completion)
        case .article: getInfo(forCV: id, completion)
        case .live:    getInfo(forLV: id, completion)
        default: break
        }
    }
    
    open func getCoverInfoBy(cover: BilibiliCover, completion: @escaping (Info?) -> Void) {
        switch cover.type {
        case .video:   getInfo(forAV: cover.number, completion)
        case .bvideo:  getInfo(forBV: cover.bvid, completion)
        case .article: getInfo(forCV: cover.number, completion)
        case .live:    getInfo(forLV: cover.number, completion)
        default: break
        }
    }
    
    private func updateServerRecord(type: CoverType, nid: String, info: Info) {
        guard let url = APIFactory.getCoverAPI(byType: type, andNID: nid, andInfo: info, env: env) else {
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
    
    private func fetchCoverRecordFromServer(withType type: CoverType, andID nid: String, _ completion: @escaping (Info?) -> Void) {
        guard let url = APIFactory.getCoverAPI(byType: type, andNID: nid, env: env) else {
            fatalError("cannot generate api url")
        }
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil,
                let content = data,
                let newInfo = try? JSONDecoder().decode(Info.self, from: content)
                else {
                    completion(nil)
                    return
            }
            if newInfo.isValid {
                completion(newInfo)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    private func getInfo(forAV: UInt64, _ completion: @escaping (Info?) -> Void) {
        BKVideo.av(Int(forAV)).getInfo {
            guard let info = try? $0.get() else {
                self.fetchCoverRecordFromServer(withType: .video, andID: String(forAV), completion)
                return
            }
            let url = info.coverImageURL.absoluteString
            let newInfo = Info(stringID: "av" + String(forAV), author: info.author.name, title: info.title, imageURL: url)
            self.updateServerRecord(type: .video, nid: String(forAV), info: newInfo)
            completion(newInfo)
        }
    }
    
    private func getInfo(forBV: String, _ completion: @escaping (Info?) -> Void) {
        BKVideo.bv(forBV).getInfo {
            guard let info = try? $0.get() else {
                self.fetchCoverRecordFromServer(withType: .bvideo, andID: forBV, completion)
                return
            }
            let url = info.coverImageURL.absoluteString
            let newInfo = Info(stringID: forBV, author: info.author.name, title: info.title, imageURL: url)
            self.updateServerRecord(type: .video, nid: forBV, info: newInfo)
            completion(newInfo)
        }
    }
    
    private func getInfo(forCV: UInt64, _ completion: @escaping (Info?) -> Void) {
        BKArticle(cv: Int(forCV)).getInfo {
            guard let info = try? $0.get() else {
                self.fetchCoverRecordFromServer(withType: .article, andID: String(forCV), completion)
                return
            }
            let url = info.coverImageURL.absoluteString
            let newInfo = Info(stringID: "cv" + String(forCV), author: info.author, title: info.title, imageURL: url)
            self.updateServerRecord(type: .article, nid: String(forCV), info: newInfo)
            completion(newInfo)
        }
    }
    
    private func getInfo(forLV: UInt64, _ completion: @escaping (Info?) -> Void) {
        BKLiveRoom(Int(forLV)).getInfo {
            guard let info = try? $0.get() else {
                self.fetchCoverRecordFromServer(withType: .live, andID: String(forLV), completion)
                return
            }
            BKUser(id: info.mid).getBasicInfo(then: { basicInfo in
                if let userInfo = try? basicInfo.get() {
                    let url = info.coverImageURL.absoluteString
                    let newInfo = Info(stringID: "lv" + String(forLV), author: userInfo.name, title: info.title, imageURL: url)
                    self.updateServerRecord(type: .live, nid: String(forLV), info: newInfo)
                    completion(newInfo)
                }
            })
        }
    }
}
