//
//  BCD+UIPasteBoard.swift
//  BCD
//
//  Created by Apollo Zhu on 9/23/17.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

struct BilibiliCover {
    let number: Int
    let type: Category
    enum Category { case video, live }
    var shortDescription: String {
        switch type {
        case .video:
            return "av\(number)"
        case .live:
            return "lv\(number)"
        }
    }
}

extension BilibiliCover {
    init(id: Int, type: Category = .video) {
        self.number = id
        self.type = type
    }
    
    init?(_ string: String) {
        var index = string.index(string.startIndex, offsetBy: 2)
        if string.hasPrefix("lv") {
            type = .live
        } else {
            type = .video
            if !string.hasPrefix("av") {
                index = string.startIndex
            }
        }
        guard let id = Int(string[index...]) else { return  nil }
        number = id
    }
    
    // TODO: Use regex?
    static func fromPasteboard() -> BilibiliCover? {
        if let urlString = UIPasteboard.general.string {
            let tempArray = Array(urlString.characters)
            var avNum = 0
            var isAvNum = false, isLvNum = false
            for i in 0..<tempArray.count {
                let j = tempArray.count - i - 1
                if let singleNum = Int("\(tempArray[j])") {
                    var num = singleNum
                    num *= Int(truncating: NSDecimalNumber(decimal: pow(10, i)))
                    avNum += num
                } else if tempArray[j] == "/" {
                    if j > 22 {
                        let index = urlString.index(urlString.startIndex, offsetBy: 21)
                        // print(urlString[..<index])
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
                    }
                } else { break }
            }
            
            
            if isAvNum || isLvNum {
                return BilibiliCover(number: avNum, type: isLvNum ? .live : .video)
            }
        }
        return nil
    }
}
