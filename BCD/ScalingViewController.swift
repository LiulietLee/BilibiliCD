
//
//  ScalingViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 28/10/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import Device

protocol ScalingViewControllerDelegate {
    func scaleSucceed(scaledImage: UIImage)
}

class ScalingViewController: UIViewController {
    
    var image = UIImage()
    var delegate: ScalingViewControllerDelegate?
    fileprivate let netModel = NetworkingModel()
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = UIImage.gif(name: "scaling")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size = image.size
        sizeLabel.text = "图片尺寸：\(size.width) x \(size.height)"
        timeLabel.text = "在我的残废 iPhone 6 上的\n预计时间：\(calculateRemainingTime(size: Double(size.width * size.height)))s"
        
        scaleImage()
    }
    
    fileprivate func calculateRemainingTime(size: Double) -> Int {
        let time = 0.0002 * size + 11.19
        return Int(time)
    }
    
    fileprivate func scaleImage() {
        let start = DispatchTime.now()
        let background = DispatchQueue(label: "background")
        background.async {
            let image_noise = self.image.run(model: .anime_noise2)?.reload()
            DispatchQueue.main.async {
                background.async {
                    let image_scale = image_noise?.scale2x().reload()?.run(model: .anime_scale2x)
                    DispatchQueue.main.async {
                        let end = DispatchTime.now()
                        let nanotime = end.uptimeNanoseconds - start.uptimeNanoseconds
                        let timeInterval = Double(nanotime) / 1_000_000_000
                        print("time: \(timeInterval)")
                        self.delegate?.scaleSucceed(scaledImage: image_scale!)
                        self.netModel.sendScaleData(type: Device.version().rawValue, size: self.image.size, time: timeInterval)
                        self.dismiss(animated: true, completion: nil)
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
