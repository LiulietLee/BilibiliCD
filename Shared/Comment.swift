//
//  Comment.swift
//  BCD
//
//  Created by Liuliet.Lee on 7/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation

struct Comment: Decodable {
    var id: Int
    var username: String
    var content: String
    var suki: Int
    var kirai: Int
    var time: Date
}

struct Reply: Decodable {
    var id: Int
    var username: String
    var content: String
    var time: Date
    var commentID: Int
}
