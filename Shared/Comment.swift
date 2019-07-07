//
//  Comment.swift
//  BCD
//
//  Created by Liuliet.Lee on 7/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation

struct Comment {
    let id: Int
    let username: String
    let content: String
    let suki: Int
    let kirai: Int
    let time: Date
}

extension Comment: Decodable {
    enum Codingkeys: String, CodingKey {
        case id = "id"
        case username = "username"
        case content = "content"
        case suki = "suki"
        case kirai = "kirai"
        case time = "time"
    }
    
    public init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: Codingkeys.self)
        id = try value.decode(Int.self, forKey: .id)
        username = try value.decode(String.self, forKey: .username)
        content = try value.decode(String.self, forKey: .content)
        suki = try value.decode(Int.self, forKey: .suki)
        kirai = try value.decode(Int.self, forKey: .kirai)
        time = try value.decode(Date.self, forKey: .time)
    }
}
