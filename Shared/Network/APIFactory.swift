//
//  APIFactory.swift
//  BCD
//
//  Created by Liuliet.Lee on 20/7/2018.
//  Copyright © 2018 Liuliet.Lee. All rights reserved.
//

import Foundation

enum Environment {
    case dev
    case prod
}

class APIFactory {
    
    static func getAPI(
        byType type: CoverType,
        andNID nid: Int? = nil,
        andInfo newInfo: Info? = nil,
        env: Environment = .prod
    ) -> URL? {
        let builder = URLBuilder().set(scheme: "http")
        
        if env == .prod {
            builder.set(host: "45.32.54.201")
        } else {
            builder.set(host: "127.0.0.1").set(port: 8000)
        }

        if type == .hotList {
            return builder.set(path: "api/hot_list").build()
        } else {
            if newInfo != nil {
                return builder.set(path: "api/db/update").build()
            } else {
                builder.set(path: "api/db/search")
            }
            
            switch type {
            case .video:   builder.addQueryItem(name: "type", value: "av")
            case .article: builder.addQueryItem(name: "type", value: "cv")
            case .live:    builder.addQueryItem(name: "type", value: "lv")
            default:       return nil
            }
            
            return builder.addQueryItem(name: "nil", value: "\(nid!)").build()
        }
        
    }
    
}
