//
//  LoadingView.swift
//  BCD
//
//  Created by Liuliet.Lee on 3/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class LoadingView: UIView {


    override func draw(_ rect: CGRect) {
        
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
