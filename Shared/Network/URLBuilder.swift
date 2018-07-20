//
//  URLBuilder.swift
//  BCD
//
//  Created by Liuliet.Lee on 20/7/2018.
//  Copyright © 2018 Liuliet.Lee. All rights reserved.
//

import Foundation

class URLBuilder {
    
    private var components: URLComponents
    
    init() {
        self.components = URLComponents()
    }
    
    @discardableResult
    func set(scheme: String) -> URLBuilder {
        self.components.scheme = scheme
        return self
    }
    
    @discardableResult
    func set(host: String) -> URLBuilder {
        self.components.host = host
        return self
    }
    
    @discardableResult
    func set(port: Int) -> URLBuilder {
        self.components.port = port
        return self
    }
    
    @discardableResult
    func set(path: String) -> URLBuilder {
        var path = path
        if !path.hasPrefix("/") {
            path = "/" + path
        }
        self.components.path = path
        return self
    }
    
    @discardableResult
    func addQueryItem(name: String, value: String) -> URLBuilder  {
        if self.components.queryItems == nil {
            self.components.queryItems = []
        }
        self.components.queryItems?.append(URLQueryItem(name: name, value: value))
        return self
    }
    
    func build() -> URL? {
        return self.components.url
    }
}
