//
//  BCD+UIPasteBoard.swift
//  BCD
//
//  Created by Apollo Zhu on 9/23/17.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

struct BilibiliCover {
    internal(set) var number: UInt64
    let type: Category
    enum Category { case video, live, article }
    var shortDescription: String {
        switch type {
        case .video:   return "av\(number)"
        case .live:    return "lv\(number)"
        case .article: return "cv\(number)"
        }
    }
    var url: URL! {
        switch type {
        case .video:   return URL(string: "https://www.bilibili.com/video/\(shortDescription)/")
        case .live:    return URL(string: "https://live.bilibili.com/\(number)")
        case .article: return URL(string: "https://www.bilibili.com/read/\(shortDescription)")
        }
    }
}

extension BilibiliCover {
    init(id: UInt64, type: Category = .video) {
        self.number = id
        self.type = type
    }
    
    init?(_ string: String) {
        var index = string.index(string.startIndex, offsetBy: 2)
        if string.hasPrefix("lv") {
            type = .live
        } else if string.hasPrefix("cv") {
            type = .article
        } else {
            type = .video
            if !string.hasPrefix("av") {
                index = string.startIndex
            }
        }
        guard let id = UInt64(string[index...]) else { return  nil }
        number = id
    }
    
    // TODO: Use regex?
    static func fromPasteboard() -> BilibiliCover? {
        if let urlString = UIPasteboard.general.string {
            
            let tempArray = Array(urlString.characters)
            var avNum = UInt64()
            var isAvNum = false, isLvNum = false, isCvNum = false
            for i in 0..<tempArray.count {
                let j = tempArray.count - i - 1
                if let singleNum = UInt64("\(tempArray[j])") {
                    let num = singleNum &* UInt64(truncating: NSDecimalNumber(decimal: pow(10, i)))
                    avNum = avNum &+ num
                } else if tempArray[j] == "/" {
                    if j > 22 {
                        let index = urlString.index(urlString.startIndex, offsetBy: 21)
                        if urlString[..<index] == "https://live.bilibili" {
                            isLvNum = true
                            break
                        }
                    }
                    continue
                } else if tempArray[j] == "v" && j >= 1 {
                    if tempArray[j - 1] == "a" {
                        isAvNum = true
                        break
                    } else if tempArray[j - 1] == "c" {
                        isCvNum = true
                        break
                    }
                } else { break }
            }
            
            
            if isAvNum || isLvNum || isCvNum {
                var type = BilibiliCover.Category.video
                if isLvNum {
                    type = .live
                } else if isCvNum {
                    type = .article
                }
                return BilibiliCover(number: avNum, type: type)
            }
        }
        return nil
    }
}

extension BilibiliCover: Equatable {
    public static func ==(lhs: BilibiliCover, rhs: BilibiliCover) -> Bool {
        return lhs.type   == rhs.type
            && lhs.number == rhs.number
    }
}
