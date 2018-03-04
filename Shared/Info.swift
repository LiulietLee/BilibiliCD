//
//  Infor.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import Foundation

public var isShowingImage = false

struct Info {
    let author: String
    let title: String
    let imageURL: String
}

extension Info: Decodable {
    enum CodingKeys: String, CodingKey {
        case uname = "uname"
        case author = "author"
        case title = "title"
        case coverURL = "cover"
        case imageURL = "url"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let uname = try values.decodeIfPresent(String.self, forKey: .uname) {
            author = uname
        } else {
            author = try values.decode(String.self, forKey: .author)
        }
        title = try values.decode(String.self, forKey: .title)
        if let coverURL = try values.decodeIfPresent(String.self, forKey: .coverURL) {
            imageURL = coverURL
        } else {
            imageURL = try values.decode(String.self, forKey: .imageURL)
        }
    }
}

extension Info {
    var isValid: Bool {
        return !imageURL.isEmpty && imageURL != "error"
    }
}

enum CitationStyle {
    case apa
    case mla
    case chicago
    

}

let italicize: [NSAttributedStringKey: Any] = [
    NSAttributedStringKey.obliqueness: 0.5 as NSNumber
]

extension Info {
    func citation(ofStyle style: CitationStyle) -> NSAttributedString {
        switch style {
        case .apa:
            let str = NSMutableAttributedString(string: "\(author). (n.d.). ")
            str.append(NSAttributedString(string: title, attributes: italicize))
            str.append(NSAttributedString(string: " [Image]. Retrieved from \(imageURL)"))
            return str
        case .mla:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let comp = formatter.string(from: Date()).components(separatedBy: " ")

            let str = NSMutableAttributedString(string: "\(author). \"\(title).\" ")
            str.append(NSAttributedString(string: "Bilibili", attributes: italicize))
            let rest = ", Shanghai Kuanyu Digital Technology, \(imageURL). Accessed \(comp[0]) \(comp[1]). \(comp[2])."
            str.append(NSAttributedString(string: rest))
            return str
        case .chicago:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            
            let str = NSMutableAttributedString(string: "\(author). ")
            str.append(NSAttributedString(string: title, attributes: italicize))
            let rest = ". Image. Bilibili. Accessed \(formatter.string(from: Date())). \(imageURL)."
            str.append(NSAttributedString(string: rest))
            return str
        }
    }
}
