//
//  TutorialContentViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 19/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class TutorialContentViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak var insideButton: UIButton!
    
    var image = UIImage()
    var index = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        
        insideButton.titleLabel!.lineBreakMode = .byWordWrapping
        if index != 6 {
            insideButton.removeFromSuperview()
        }
    }

    @IBAction func goInside() {
        let vc = HisTutViewController()
        present(vc, animated: true, completion: nil)
    }
}
