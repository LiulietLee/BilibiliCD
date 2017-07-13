//
//  LoadingView.swift
//  BCD
//
//  Created by Liuliet.Lee on 3/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    fileprivate var active = MKActivityIndicator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    fileprivate func setup() {
        self.backgroundColor = .white
        let width = self.bounds.size.width
        let height = self.bounds.size.height
        let x = width * 0.375
        let y = height * 0.375
        let w = width * 0.25
        let f = CGRect(x: x, y: y, width: w, height: w)
        active.frame = f
        active.color = UIColor(red: 1.06, green: 0.403, blue: 0.599, alpha: 1.0)
        self.addSubview(active)
        self.bringSubview(toFront: active)
        active.startAnimating()
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
