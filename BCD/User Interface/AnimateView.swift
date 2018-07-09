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
            if let _ = view as? LoadingView { continue }
            view.animate(animations: [type], delay: delay)
        }
    }
    
    func animateTableView(type: AnimationType) {
        let interval = ViewAnimatorConfig.interval
        for (_, view) in self.subviews.enumerated() {
            if let tableView = view as? UITableView {
                var index = 0
                for cell in tableView.visibleCells {
                    let delay = Double(index) * interval
                    cell.animate(animations: [type], delay: delay)
                    index += 1
                }
                break
            }
        }
    }
}
