//
//  LoadingView.swift
//  BCD
//
//  Created by Liuliet.Lee on 3/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import MaterialKit

class LoadingView: UIView {

    fileprivate var indicator = MKActivityIndicator()
    var color = UIColor.bilibiliPink

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        backgroundColor = .white
        let width = bounds.size.width
        let height = bounds.size.height
        let x = width * 0.375
        let y = height * 0.375
        let w = width * 0.25
        let f = CGRect(x: x, y: y, width: w, height: w)
        indicator.frame = f
        indicator.color = color
        addSubview(indicator)
        bringSubview(toFront: indicator)
        indicator.startAnimating()
    }
    
    public func dismiss() {
        UIView.animate(
            withDuration: 0.5,
            animations: { [weak self] in
                self?.alpha = 0.0
            },
            completion: { [weak self] _ in
                self?.removeFromSuperview()
        })
    }
    
}
