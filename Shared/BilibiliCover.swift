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
    
    init?(_ shortDescription: String) {
        var index = shortDescription.index(shortDescription.startIndex, offsetBy: 2)
        if shortDescription.hasPrefix("lv") {
            type = .live
        } else if shortDescription.hasPrefix("cv") {
            type = .article
        } else {
            type = .video
            if !shortDescription.hasPrefix("av") {
                index = shortDescription.startIndex
            }
        }
        guard let id = UInt64(shortDescription[index...]) else { return nil }
        number = id
    }
}

extension BilibiliCover: Equatable {
    public static func ==(lhs: BilibiliCover, rhs: BilibiliCover) -> Bool {
        return lhs.type   == rhs.type
            && lhs.number == rhs.number
    }
}

extension BilibiliCover {
    static let avNumberMatcher = try! NSRegularExpression(pattern: "(?<=av)\\d+")
    static let cvNumberMatcher = try! NSRegularExpression(pattern: "(?<=cv)\\d+")
    static let numberMatcher = try! NSRegularExpression(pattern: "\\d+")
    
    static func fromPasteboard() -> BilibiliCover? {
        guard let urlString = UIPasteboard.general.string else { return nil }
        if let avNumber = avNumberMatcher.numberFound(in: urlString) {
            return BilibiliCover(number: avNumber, type: .video)
        } else if let cvNumber = cvNumberMatcher.numberFound(in: urlString) {
            return BilibiliCover(number: cvNumber, type: .article)
        } else if urlString.contains("live.bilibili")
            , let number = numberMatcher.numberFound(in: urlString) {
            return BilibiliCover(number: number, type: .live)
        } else { return nil }
    }
}

extension NSRegularExpression {
    fileprivate func numberFound(in string: String) -> UInt64? {
        let nsRange = NSRange(string.startIndex..<string.endIndex, in: string)
        guard let matchNSRange = firstMatch(in: string, range: nsRange)?.range
            , let matchRange = Range(matchNSRange, in: string)
            else { return nil }
        return UInt64(string[matchRange])
    }
}
