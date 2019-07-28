//
//  Response.swift
//  BCD
//
//  Created by Liuliet.Lee on 28/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation

struct ListResponse<T: Decodable>: Decodable {
    var count: Int
    var data: [T]
}

struct MessageResponse<T: Decodable>: Decodable {
    var status: Int
    var message: String
    var data: T?
}
