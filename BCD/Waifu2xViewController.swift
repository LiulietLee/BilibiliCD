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

class Waifu2xViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    var originImage: UIImage?
    var delegate: Waifu2xDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if originImage == nil {
            startButton.isEnabled = false
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
        let start = DispatchTime.now()
        let background = DispatchQueue(label: "background")
        background.async {
            let image_noise = self.originImage!.run(model: .anime_noise2)?.reload()
            DispatchQueue.main.async {
                background.async {
                    let image_scale = image_noise?.scale2x().reload()?.run(model: .anime_scale2x)
                    DispatchQueue.main.async {
                        let end = DispatchTime.now()
                        let nanotime = end.uptimeNanoseconds - start.uptimeNanoseconds
                        let timeInterval = Double(nanotime) / 1_000_000_000
                        print("time: \(timeInterval)")
                        self.delegate?.scaleSucceed(scaledImage: image_scale!)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
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
