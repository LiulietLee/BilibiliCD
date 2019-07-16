//
//  Comment.swift
//  BCD
//
//  Created by Liuliet.Lee on 7/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation

struct Comment: Decodable {
    let id: Int
    let username: String
    let content: String
    let suki: Int
    let kirai: Int
    let time: Date
}

struct Reply: Decodable {
    let id: Int
    let username: String
    let content: String
    let time: Date
    let commentID: Int
}
