//
//  DetailViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 1/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import ViewAnimator

class DetailViewController: UIViewController {
    
    var image: UIImage?
    var isHidden: Bool? = nil
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var yConstraint: NSLayoutConstraint!
    @IBOutlet weak var xConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isShowingImage = true
        if let img = image {
            imageView.image = img
            widthConstraint.constant = view.bounds.size.width
        } else {
            print("no image here")
        }
        
        let type = AnimationType.from(direction: .right, offset: ViewAnimatorConfig.offset)
        view.doAnimation(type: type)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(goBackIfNeeded),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    @objc private func goBackIfNeeded() {
        if isHidden == true {
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main") as! MainViewController
            
            show(nextViewController, sender: self)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        xConstraint.constant = 0
        yConstraint.constant = 0
        widthConstraint.constant = view.bounds.size.width
    }
    
    @IBAction func move(_ sender: UIPanGestureRecognizer) {
        let translate = sender.translation(in: view)
        xConstraint.constant += translate.x
        yConstraint.constant += translate.y
        sender.setTranslation(.zero, in: view)
    }

    @IBAction func zoom(_ sender: UIPinchGestureRecognizer) {
        widthConstraint.constant *= sender.scale
        xConstraint.constant *= sender.scale
        yConstraint.constant *= sender.scale
        sender.scale = 1.0
    }

    @IBAction func zoomIn(_ sender: UITapGestureRecognizer) {
        widthConstraint.constant *= 3.0
        xConstraint.constant *= 3.0
        yConstraint.constant *= 3.0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}
