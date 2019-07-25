//
//  AbstractProvider.swift
//  BCD
//
//  Created by Liuliet.Lee on 27/9/2018.
//  Copyright © 2018 Liuliet.Lee. All rights reserved.
//

import Foundation

struct ListResponse<T: Decodable>: Decodable {
    var count: Int
    var data: [T]
}

class AbstractProvider {
    
    internal let session = URLSession.shared
    internal let env = Environment.dev
    
}
