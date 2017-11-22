
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
    var protoc = [0, 2, 1]
    var selectNoiseModel = [
        [Model.none, Model.anime_noise0, Model.anime_noise1, Model.anime_noise2, Model.anime_noise3],
        [Model.none, Model.photo_noise0, Model.photo_noise1, Model.photo_noise2, Model.photo_noise3]
    ]
    var selectScaleModel = [
        [Model.none, Model.anime_scale2x],
        [Model.none, Model.photo_scale2x]
    ]

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
        timeLabel.text = "其实我是想做个进度条来着...\n但是又做不粗来...\n所以就全当这里有进度条了吧"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (protoc[1] == 0 && protoc[2] == 0) {
            self.delegate?.scaleSucceed(scaledImage: image)
            self.dismiss(animated: true, completion: nil)
        } else {
            scaleImage()
        }
    }
    
//    fileprivate func calculateRemainingTime(size: Double) -> Int {
//        let time = 0.0002 * size + 11.19
//        return Int(time)
//    }
    
    fileprivate func scaleImage() {
        let start = DispatchTime.now()
        let background = DispatchQueue(label: "background")
        
        background.async {
            var image_noise = self.image
            if (self.protoc[1] != 0) {
                image_noise = (self.image.run(model: self.selectNoiseModel[self.protoc[0]][self.protoc[1]])?.reload())!
            }
        
            // 这段还没测，撑不住了先睡觉了
            if (self.protoc[2] != 0) {
                DispatchQueue.main.async {
                    background.async {
                        let image_scale = image_noise.scale2x().reload()?.run(model: self.selectNoiseModel[self.protoc[0]][self.protoc[2]])
                        DispatchQueue.main.async {
                            let end = DispatchTime.now()
                            let nanotime = end.uptimeNanoseconds - start.uptimeNanoseconds
                            let timeInterval = Double(nanotime) / 1_000_000_000
                            print("time: \(timeInterval)")
                            self.delegate?.scaleSucceed(scaledImage: image_scale!)
                            // self.netModel.sendScaleData(type: Device.version().rawValue, size: self.image.size, time: timeInterval)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            } else {
                self.delegate?.scaleSucceed(scaledImage: image_noise)
                // self.netModel.sendScaleData(type: Device.version().rawValue, size: self.image.size, time: timeInterval)
                self.dismiss(animated: true, completion: nil)
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
