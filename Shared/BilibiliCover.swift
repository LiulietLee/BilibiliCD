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
    case bvideo = 2
    case article = 3
    case live = 4
    case hotList = 5
    
    static func stringType(type: CoverType) -> String? {
        switch type {
        case .video:   return "av"
        case .article: return "cv"
        case .live:    return "lv"
        case .bvideo:  return "BV"
        default:       return nil
        }
    }
}

struct BilibiliCover {
    var number: UInt64
    var bvid: String
    let type: CoverType
    var shortDescription: String {
        switch type {
        case .video:   return "av\(number)"
        case .live:    return "lv\(number)"
        case .article: return "cv\(number)"
        case .bvideo:  return "BV\(bvid)"
        default:       fatalError("todo \(type)")
        }
    }
    var url: URL! {
        switch type {
        case .video, .bvideo: return URL(string: "https://www.bilibili.com/video/\(shortDescription)/")
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
        self.bvid = ""
    }
    
    init(bvid: String, type: CoverType = .bvideo) {
        self.type = type
        self.number = 1
        self.bvid = bvid
    }
    
    init?(_ shortDescription: String) {
        var index = shortDescription.index(shortDescription.startIndex, offsetBy: 2)
        if shortDescription.hasPrefix("lv") {
            type = .live
        } else if shortDescription.hasPrefix("cv") {
            type = .article
        } else if shortDescription.hasPrefix("BV") {
            type = .bvideo
        } else {
            type = .video
            if !shortDescription.hasPrefix("av") {
                index = shortDescription.startIndex
            }
        }
        if let id = UInt64(shortDescription[index...]) {
            number = id
            bvid = ""
        } else {
            number = 0
            bvid = String(shortDescription[index...])
        }
    }
}

extension BilibiliCover: Equatable {
    public static func ==(lhs: BilibiliCover, rhs: BilibiliCover) -> Bool {
        return lhs.type   == rhs.type
            && lhs.number == rhs.number
            && lhs.bvid   == rhs.bvid
    }
}

import Alamofire

extension BilibiliCover {
    static let avNumberMatcher = try! NSRegularExpression(pattern: "(?<=av)\\d+")
    static let bvidMatcher     = try! NSRegularExpression(pattern: "(?<=BV)[A-Za-z0-9]+")
    static let cvNumberMatcher = try! NSRegularExpression(pattern: "(?<=cv)\\d+")
    static let lvNumberMatcher = try! NSRegularExpression(pattern: "(?<=\\/)\\d+")

    typealias Handler = (BilibiliCover?) -> Void
    
    static func fromPasteboard(then handle: @escaping Handler) {
        guard let urlString = UIPasteboard.general.string
            else { return handle(nil) }
        BilibiliCover.fromURL(urlString, then: handle)
    }
    
    static func fromURL(_ urlString: String, then handle: @escaping Handler) {
        if let avNumber = avNumberMatcher.numberFound(in: urlString) {
            handle(BilibiliCover(id: avNumber, type: .video))
        } else if let cvNumber = cvNumberMatcher.numberFound(in: urlString) {
            handle(BilibiliCover(id: cvNumber, type: .article))
        } else if urlString.contains("live.bilibili")
            , let number = lvNumberMatcher.numberFound(in: urlString) {
            handle(BilibiliCover(id: number, type: .live))
        } else if let matchNSRange = bvidMatcher.firstMatch(
                in: urlString,
                range: NSRange(urlString.startIndex..<urlString.endIndex, in: urlString)
            )?.range,
            let matchRange = Range(matchNSRange, in: urlString) {
            handle(BilibiliCover(bvid: String(urlString[matchRange])))
        } else if urlString.contains("b23.tv") {
            Session.noRedirect.request(urlString).response { res in
                if let location = res.response?.allHeaderFields["Location"] as? String {
                    fromURL(location, then: handle)
                } else {
                    handle(nil)
                }
            }
        } else { handle(nil) }
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
