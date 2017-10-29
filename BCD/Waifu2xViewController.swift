//
//  Waifu2xViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 27/10/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

protocol Waifu2xDelegate {
    func scaleSucceed(scaledImage: UIImage)
}

class Waifu2xViewController: UIViewController, ScalingViewControllerDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    var originImage: UIImage?
    var delegate: Waifu2xDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if originImage == nil {
            if originImage!.size.width > 150,
                originImage!.size.height > 150,
                originImage!.size.width < 1200,
                originImage!.size.height < 1200 {
                startButton.isEnabled = false
            }
        }
        
        print("image width: \(originImage!.size.width), height: \(originImage!.size.height)")
    }
    
    @IBAction func openTut() {
        let vc = HisTutViewController()
        vc.page = "AboutWaifu2x"
        present(vc, animated: true, completion: nil)

    }
    
    @IBAction func startScale() {
        startButton.isEnabled = false
    }
    
    func scaleSucceed(scaledImage: UIImage) {
        delegate?.scaleSucceed(scaledImage: scaledImage)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ScalingViewController {
            vc.image = originImage!
            vc.delegate = self
        }
    }

}
