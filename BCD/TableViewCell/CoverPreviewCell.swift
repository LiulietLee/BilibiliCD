//
//  CoverPreviewCell.swift
//  BCD
//
//  Created by Liuliet.Lee on 1/10/2018.
//  Copyright © 2018 Liuliet.Lee. All rights reserved.
//

import UIKit
import MaterialKit

class CoverPreviewCell: MKTableViewCell {
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        coverView.layer.masksToBounds = true
        coverView.layer.cornerRadius = 5.0
    }
    
}
