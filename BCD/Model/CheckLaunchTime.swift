//
//  CheckLaunchTime.swift
//  BCD
//
//  Created by Liuliet.Lee on 22/10/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

private func never(_ key: String) -> Bool {
    let defaults = UserDefaults.standard
    
    if defaults.bool(forKey: key) {
        return false
    } else {
        defaults.set(true, forKey: key)
        return true
    }
}

public var needToDisplayAppTutorial: Bool {
    return never("needToDisplayAppTutorial")
}

public var needToDisplayHistoryTutorial: Bool {
    return never("isNeedToDisplayHisTut")
}

public var needToDisplayAutoHideTutorial: Bool {
    return UserDefaults.standard.bool(forKey: "isNeedToDisplayHisTut")
        && never("isNeedToDisplayAutoHis")
}

public var needToSetSaveOriginTrue: Bool {
    return never("isNeedToSetSaveOriginTrue")
}
