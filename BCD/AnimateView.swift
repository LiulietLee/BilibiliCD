//
//  AnimateView.swift
//  BCD
//
//  Created by Liuliet.Lee on 15/10/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import ViewAnimator

extension UIView {
    func doAnimation(type: AnimationType) {
        let interval = ViewAnimatorConfig.interval
        for (index, view) in self.subviews.enumerated() {
            let delay = Double(index) * interval
            if let animatable = view as? Animatable {
                animatable.animateViews(animationType: type, delay: delay)
            } else {
                view.animate(animationType: type, delay: delay)
            }
        }
    }
}
