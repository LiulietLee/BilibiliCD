//
//  ReplyCell.swift
//  BCD
//
//  Created by Liuliet.Lee on 15/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit

class ReplyCell: UITableViewCell {

    var data: Reply! {
        didSet {
            self.username.text = data.username
            self.content.text = data.content
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yy.MM.dd hh:mm"
            self.date.text = formatter.string(from: data.time)
        }
    }
    
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
