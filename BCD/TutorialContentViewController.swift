//
//  TutorialContentViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 19/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class TutorialContentViewController: UIViewController {
    
    @IBOutlet weak var topCons: NSLayoutConstraint!
    @IBOutlet weak var bottomCons: NSLayoutConstraint!
    @IBOutlet private weak var imageView: UIImageView!
    
    var image = UIImage()
    var index = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        
//        if UIDevice().userInterfaceIdiom == .phone {
//            if UIScreen.main.nativeBounds.height == 2436 {
//                // iPhone X
//                topCons.constant = 0.0
//                bottomCons.constant = 0.0
//                view.layoutIfNeeded()
//            }
//        }
    }

}
