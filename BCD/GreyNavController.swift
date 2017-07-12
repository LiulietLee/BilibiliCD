//
//  GreyNavController.swift
//  BCD
//
//  Created by Liuliet.Lee on 11/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class GreyNavController: ColoredNavController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barTintColor = UIColor(red: 0.277, green: 0.282, blue: 0.317, alpha: 1.0)
    }
}
