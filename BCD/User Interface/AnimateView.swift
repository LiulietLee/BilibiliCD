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
        for (index, view) in subviews.enumerated()
            where !(view is LoadingView) {
            let delay = Double(index) * interval
            view.animate(animations: [type], delay: delay)
        }
    }
    
    func animateTableView(type: AnimationType) {
        let interval = ViewAnimatorConfig.interval
        guard let tableView = subviews.lazy
            .compactMap({ $0 as? UITableView }).first
            else { return }
        for (index, cell) in tableView.visibleCells.enumerated() {
            let delay = Double(index) * interval
            cell.animate(animations: [type], delay: delay)
        }
    }

    @available(iOS 13.4, *)
    @IBInspectable
    public var isPointerInteractionEnabled: Bool {
        get {
            return interactions.contains { $0 is UIPointerInteraction }
        }
        set(setEnabled) {
            if setEnabled {
                addInteraction(UIPointerInteraction())
            } else {
                interactions.removeAll { $0 is UIPointerInteraction }
            }
        }
    }
}
