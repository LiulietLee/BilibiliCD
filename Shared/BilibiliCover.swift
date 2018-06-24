//
//  BCD+UIPasteBoard.swift
//  BCD
//
//  Created by Apollo Zhu on 9/23/17.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

enum CoverType: Int {
    case none = 0
    case video = 1
    case article = 2
    case live = 3
    case hotList = 4
    
    static func stringType(type: CoverType) -> String? {
        switch type {
        case .video:   return "av"
        case .article: return "cv"
        case .live:    return "lv"
        default:       return nil
        }
    }
}

struct BilibiliCover {
    internal(set) var number: UInt64
    let type: CoverType
    var shortDescription: String {
        switch type {
        case .video:   return "av\(number)"
        case .live:    return "lv\(number)"
        case .article: return "cv\(number)"
        default:       fatalError("todo \(type)")
        }
    }
    var url: URL! {
        switch type {
        case .video:   return URL(string: "https://www.bilibili.com/video/\(shortDescription)/")
        case .live:    return URL(string: "https://live.bilibili.com/\(number)")
        case .article: return URL(string: "https://www.bilibili.com/read/\(shortDescription)")
        default:       fatalError("todo \(type)")
        }
    }
}

extension BilibiliCover {
    init(id: UInt64, type: CoverType = .video) {
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
    static let lvNumberMatcher = try! NSRegularExpression(pattern: "(?<=\\/)\\d+")
    
    static func fromPasteboard() -> BilibiliCover? {
        guard let urlString = UIPasteboard.general.string else { return nil }
        return BilibiliCover.fromURL(urlString)
    }
    
    static func fromURL(_ urlString: String) -> BilibiliCover? {
        if let avNumber = avNumberMatcher.numberFound(in: urlString) {
            return BilibiliCover(number: avNumber, type: .video)
        } else if let cvNumber = cvNumberMatcher.numberFound(in: urlString) {
            return BilibiliCover(number: cvNumber, type: .article)
        } else if urlString.contains("live.bilibili")
            , let number = lvNumberMatcher.numberFound(in: urlString) {
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
