//
//  DetailViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 1/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var image: UIImage?
    fileprivate var isZoomedIn = false
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var yConstraint: NSLayoutConstraint!
    @IBOutlet weak var xConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let img = image {
            imageView.image = img
            widthConstraint.constant = view.bounds.size.width
        } else {
            print("no image here")
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
        sender.setTranslation(CGPoint.zero, in: view)
    }

    @IBAction func zoom(_ sender: UIPinchGestureRecognizer) {
        widthConstraint.constant *= sender.scale
        xConstraint.constant *= sender.scale
        yConstraint.constant *= sender.scale
        sender.scale = 1.0
    }
    
    @IBAction func zoomIn(_ sender: UITapGestureRecognizer) {
        let scale: CGFloat = 3
        if !isZoomedIn {
            self.widthConstraint.constant *= scale
            self.xConstraint.constant *= scale
            self.yConstraint.constant *= scale
        } else {
            self.widthConstraint.constant /= scale
            self.xConstraint.constant /= scale
            self.yConstraint.constant /= scale
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        isZoomedIn = !isZoomedIn
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
