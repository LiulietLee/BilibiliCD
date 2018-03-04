//
//  Infor.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import Foundation

public var isShowingImage = false

struct Info {
    let author: String
    let title: String
    let imageURL: String
}

extension Info: Decodable {
    enum CodingKeys: String, CodingKey {
        case uname = "uname"
        case author = "author"
        case title = "title"
        case coverURL = "cover"
        case imageURL = "url"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let uname = try values.decodeIfPresent(String.self, forKey: .uname) {
            author = uname
        } else {
            author = try values.decode(String.self, forKey: .author)
        }
        title = try values.decode(String.self, forKey: .title)
        if let coverURL = try values.decodeIfPresent(String.self, forKey: .coverURL) {
            imageURL = coverURL
        } else {
            imageURL = try values.decode(String.self, forKey: .imageURL)
        }
    }
}

extension Info {
    var isValid: Bool {
        return !imageURL.isEmpty && imageURL != "error"
    }
}
