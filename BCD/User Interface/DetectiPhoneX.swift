//
//  DetectiPhoneX.swift
//  BCD
//
//  Created by Liuliet.Lee on 13/10/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import LocalAuthentication

extension UIDevice {
    var supportsFaceID: Bool {
        var nsError: NSError?
        let context = LAContext()
        context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &nsError)
        switch context.biometryType {
        case .faceID:
            return true
        case .touchID, .none:
            return false
        @unknown default:
            return true
        }
    }
}
