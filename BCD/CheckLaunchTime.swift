//
//  CheckLaunchTime.swift
//  BCD
//
//  Created by Liuliet.Lee on 22/10/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

public var isNeedToDisplayHisTut: Bool {
    let defaults = UserDefaults.standard
    
    if defaults.string(forKey: "isNeedToDisplayHisTut") != nil{
        return false
    } else {
        defaults.set(true, forKey: "isNeedToDisplayHisTut")
        return true
    }
}

public var isNeedToDisplayAutoHis: Bool {
    let defaults = UserDefaults.standard
    
    if defaults.string(forKey: "isNeedToDisplayHisTut") != nil{
        if defaults.string(forKey: "isNeedToDisplayAutoHis") != nil{
            return false
        } else {
            defaults.set(true, forKey: "isNeedToDisplayAutoHis")
            return true
        }
    } else {
        return false
    }

}
