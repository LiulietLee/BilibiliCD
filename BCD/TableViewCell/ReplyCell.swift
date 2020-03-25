//
//  ReplyCell.swift
//  BCD
//
//  Created by Liuliet.Lee on 15/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit
import MaterialKit

class ReplyCell: MKTableViewCell {

    var data: Reply! {
        didSet {
            self.username.text = data.username
            self.content.text = data.content

            self.date.text = DateFormatter.shortStyle.string(from: data.time)
        }
    }
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var date: UILabel!

}
