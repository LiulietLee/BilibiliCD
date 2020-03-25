//
//  CommentCell.swift
//  BCD
//
//  Created by Liuliet.Lee on 11/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit
import MaterialKit

extension DateFormatter {
    static let shortStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

class CommentCell: MKTableViewCell {

    var data: Comment! {
        didSet {
            self.username.text = data.username
            self.content.text = data.content

            func format(_ keyPath: KeyPath<Comment, Int>) -> String {
                let number = data?[keyPath: keyPath] ?? 0
                return number > 999 ? "  999+" : "  \(number)"
            }
            
            self.likeButton.setTitle(format(\.suki), for: .normal)
            self.dislikeButton.setTitle(format(\.kirai), for: .normal)
            self.replyCount.setTitle(format(\.replyCount), for: .normal)

            self.date.text = DateFormatter.shortStyle.string(from: data.time)
        }
    }
    
    var liked: Bool! {
        didSet {
            if liked {
                likeButton.setImage(UIImage(named: "ic_suki_tapped"), for: .normal)
            } else {
                likeButton.setImage(UIImage(named: "ic_suki"), for: .normal)
            }
        }
    }
    
    var disliked: Bool! {
        didSet {
            if disliked {
                dislikeButton.setImage(UIImage(named: "ic_kirai_tapped"), for: .normal)
            } else {
                dislikeButton.setImage(UIImage(named: "ic_kirai"), for: .normal)
            }
        }
    }
    
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var replyCount: UIButton! {
        didSet {
            replyCount.isEnabled = false
        }
    }

}
