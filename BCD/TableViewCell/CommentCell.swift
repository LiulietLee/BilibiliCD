//
//  CommentCell.swift
//  BCD
//
//  Created by Liuliet.Lee on 11/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    var data: Comment! {
        didSet {
            self.username.text = data.username
            self.content.text = data.content
            self.likeButton.setTitle("  \(data.suki)", for: .normal)
            self.dislikeButton.setTitle("  \(data.kirai)", for: .normal)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yy.MM.dd hh:mm"
            self.date.text = formatter.string(from: data.time)
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
