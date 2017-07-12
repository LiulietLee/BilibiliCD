//
//  ColoredNavController.swift
//  BCD
//
//  Created by Liuliet.Lee on 11/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class ColoredNavController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationBar.layer.shadowOffset = CGSize(width: 0.1, height: 0.1)
        navigationBar.layer.shadowRadius = 1.5
        navigationBar.layer.shadowOpacity = 1.0
    }
}

extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
