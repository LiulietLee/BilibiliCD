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
    
    private func updateServerRecord(type: CoverType, nid: UInt64, info: Info) {
        guard let url = APIFactory.getAPI(byType: type, andNID: Int(nid), andInfo: info, env: env) else {
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
    
    private func fetchCoverRecordFromServer(withType type: CoverType, andID nid: UInt64, _ completion: @escaping (Info?) -> Void) {
        guard let url = APIFactory.getAPI(byType: type, andNID: Int(nid), env: env) else {
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
        BKVideo(av: Int(forAV)).getInfo {
            guard let info = $0 else {
                self.fetchCoverRecordFromServer(withType: .video, andID: forAV, completion)
                return
            }
            let url = info.coverImageURL.absoluteString
            let newInfo = Info(stringID: "av" + String(forAV), author: info.author, title: info.title, imageURL: url)
            self.updateServerRecord(type: .video, nid: forAV, info: newInfo)
            completion(newInfo)
        }
    }
    
    private func getInfo(forCV: UInt64, _ completion: @escaping (Info?) -> Void) {
        BKArticle(cv: Int(forCV)).getInfo {
            guard let info = $0 else {
                self.fetchCoverRecordFromServer(withType: .article, andID: forCV, completion)
                return
            }
            let url = info.coverImageURL.absoluteString
            let newInfo = Info(stringID: "cv" + String(forCV), author: info.author, title: info.title, imageURL: url)
            self.updateServerRecord(type: .article, nid: forCV, info: newInfo)
            completion(newInfo)
        }
    }
    
    private func getInfo(forLV: UInt64, _ completion: @escaping (Info?) -> Void) {
        BKLiveRoom(Int(forLV)).getInfo {
            guard let info = $0 else {
                self.fetchCoverRecordFromServer(withType: .live, andID: forLV, completion)
                return
            }
            BKUser(id: info.mid).getBasicInfo(then: { basicInfo in
                if let userInfo = basicInfo {
                    let url = info.coverImageURL.absoluteString
                    let newInfo = Info(stringID: "lv" + String(forLV), author: userInfo.name, title: info.title, imageURL: url)
                    self.updateServerRecord(type: .live, nid: forLV, info: newInfo)
                    completion(newInfo)
                }
            })
        }
    }
}
