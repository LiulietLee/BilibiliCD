//
//  CheckLaunchTime.swift
//  BCD
//
//  Created by Liuliet.Lee on 22/10/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

public var isAppAlreadyLaunchedOnce: Bool {
    let defaults = UserDefaults.standard
    
    if defaults.string(forKey: "isAppAlreadyLaunchedOnce") != nil{
        return true
    } else {
        defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
        return false
    }
}

public var isAppAlreadyLaunchedTwice: Bool {
    let defaults = UserDefaults.standard
    
    if defaults.string(forKey: "isAppAlreadyLaunchedOnce") != nil{
        if defaults.string(forKey: "isAppAlreadyLaunchedTwice") != nil{
            return true
        } else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedTwice")
            return false
        }
    } else {
        return true
    }

}
