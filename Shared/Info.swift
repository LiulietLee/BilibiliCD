//
//  Infor.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import Foundation
import UIKit

public var isShowingImage = false

struct Info {
    let author: String
    let title: String
    let imageURL: String
}

extension Info: Decodable {
    enum CodingKeys: String, CodingKey {
        case author = "author"
        case title = "title"
        case imageURL = "url"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        author = try values.decode(String.self, forKey: .author)
        title = try values.decode(String.self, forKey: .title)
        imageURL = try values.decode(String.self, forKey: .imageURL)
    }
}

extension Info {
    var isValid: Bool {
        return !imageURL.isEmpty && imageURL != "error"
    }
}

enum CitationStyle: Int {
    case apa
    case mla
    case chicago
}

let italicize: [NSAttributedStringKey: Any] = [
    .obliqueness: 0.5 as NSNumber
]

let paraStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.headIndent = 36
    style.lineHeightMultiple = 2
    return style
}()

let hangingIndent: [NSAttributedStringKey: Any] = [
    .paragraphStyle: paraStyle,
    .font: UIFont(name: "Times New Roman", size: 12) ?? UIFont.systemFont(ofSize: 12)
]

extension DateFormatter {
    static let mla: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    static let chicago: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

extension Info {
    func citation(ofStyle style: CitationStyle) -> NSAttributedString {
        let str: NSMutableAttributedString
        switch style {
        case .apa:
            str = NSMutableAttributedString(string: "\(author). (n.d.). ")
            str.append(NSAttributedString(string: title, attributes: italicize))
            str.append(NSAttributedString(string: " [Image]. Retrieved from \(imageURL)"))
        case .mla:
            let comp = DateFormatter.mla.string(from: Date()).components(separatedBy: " ")
            str = NSMutableAttributedString(string: "\(author). \"\(title).\" ")
            str.append(NSAttributedString(string: "Bilibili", attributes: italicize))
            let rest = ", Shanghai Kuanyu Digital Technology, \(imageURL). Accessed \(comp[0]) \(comp[1]). \(comp[2])."
            str.append(NSAttributedString(string: rest))
        case .chicago:
            str = NSMutableAttributedString(string: "\(author). ")
            str.append(NSAttributedString(string: title, attributes: italicize))
            let rest = ". Image. Bilibili. Accessed \(DateFormatter.chicago.string(from: Date())). \(imageURL)."
            str.append(NSAttributedString(string: rest))
        }
        str.addAttributes(hangingIndent, range: NSRange(location: 0, length: str.length))
        return str
    }
}
