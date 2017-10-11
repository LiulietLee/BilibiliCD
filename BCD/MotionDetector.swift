//
//  MotionDetector.swift
//  BCD
//
//  Created by Liuliet.Lee on 11/10/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import Foundation
import CoreMotion

protocol MotionDetectorDelegate {
    func openInsideWorld()
}

class MotionDetector {
    
    var delegate: MotionDetectorDelegate?
    
    fileprivate let motionManager = CMMotionManager()
    fileprivate let timeInterval: TimeInterval = 0.5
    
    func beginDetect() {
        guard motionManager.isGyroAvailable else {
            print("don't support core motion")
            return
        }
        
        self.motionManager.accelerometerUpdateInterval = self.timeInterval
        
        let queue = OperationQueue.current
        motionManager.startAccelerometerUpdates(to: queue!, withHandler: { (data, error) in
            guard error == nil else {
                print(error!)
                return
            }

            if self.motionManager.isAccelerometerActive {
                if let rotation = data?.acceleration {
                    if rotation.y > 0.85 {
                        self.delegate?.openInsideWorld()
                    }
                }
            }
        })
    }
    
    func endDetect() {
        motionManager.stopAccelerometerUpdates()
    }
    
}
