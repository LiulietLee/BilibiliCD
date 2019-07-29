//
//  CommentCell.swift
//  BCD
//
//  Created by Liuliet.Lee on 11/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit
import MaterialKit

class CommentCell: MKTableViewCell {

    var data: Comment! {
        didSet {
            self.username.text = data.username
            self.content.text = data.content
            self.likeButton.setTitle(
                "  \(data.suki > 999 ? 999 : data.suki)" + (data.suki > 999 ? "+" : ""),
                for: .normal
            )
            self.dislikeButton.setTitle(
                "  \(data.kirai > 999 ? 999 : data.kirai)" + (data.kirai > 999 ? "+" : ""),
                for: .normal
            )
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yy.MM.dd hh:mm"
            self.date.text = formatter.string(from: data.time)
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
