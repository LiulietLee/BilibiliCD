//
//  DetectiPhoneX.swift
//  BCD
//
//  Created by Liuliet.Lee on 13/10/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

extension UIDevice {
    var isiPhoneX: Bool {
        if self.userInterfaceIdiom == .phone {
            return UIScreen.main.nativeBounds.height == 2436
        }
        return false
    }
}
