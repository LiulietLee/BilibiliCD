
//
//  ScalingViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 28/10/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import Device

protocol ScalingViewControllerDelegate: AnyObject {
    func scaleSucceed(scaledImage: UIImage)
}

class ScalingViewController: UIViewController {
    
    var image = UIImage()
    weak var delegate: ScalingViewControllerDelegate?
    var protoc = [0, 2, 1]
    private let netModel = NetworkingModel()
    private let selectNoiseModel: [[Model]] = [
        [.none, .anime_noise0, .anime_noise1, .anime_noise2, .anime_noise3],
        [.none, .photo_noise0, .photo_noise1, .photo_noise2, .photo_noise3]
    ]
    private let selectScaleModel: [[Model]] = [
        [.none, .anime_scale2x],
        [.none, .photo_scale2x]
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
        // TODO: - progress bar
        timeLabel.text = "其实我是想做个进度条来着...\n但是又做不粗来...\n所以就全当这里有进度条了吧"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if protoc[1] == 0 && protoc[2] == 0 {
            self.delegate?.scaleSucceed(scaledImage: image)
            self.dismiss(animated: true, completion: nil)
        } else {
            scaleImage()
        }
    }
    
//    private func calculateRemainingTime(size: Double) -> Int {
//        let time = 0.0002 * size + 11.19
//        return Int(time)
//    }
    
    private func scaleImage() {
        let start = DispatchTime.now()
        let background = DispatchQueue(label: "background")
        
        background.async {
            var image_noise = self.image
            if self.protoc[1] != 0 {
                image_noise = (self.image.run(model: self.selectNoiseModel[self.protoc[0]][self.protoc[1]])?.reload())!
            }
        
            if self.protoc[2] != 0 {
                DispatchQueue.main.async {
                    background.async {
                        let image_scale = image_noise.scale2x().reload()?.run(model: self.selectNoiseModel[self.protoc[0]][self.protoc[2]])
                        let end = DispatchTime.now()
                        let nanotime = end.uptimeNanoseconds - start.uptimeNanoseconds
                        let timeInterval = Double(nanotime) / 1_000_000_000
                        print("time: \(timeInterval)")
                        // self.netModel.sendScaleData(type: Device.version().rawValue, size: self.image.size, time: timeInterval)
                        DispatchQueue.main.async {
                            self.delegate?.scaleSucceed(scaledImage: image_scale!)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.delegate?.scaleSucceed(scaledImage: image_noise)
                    // self.netModel.sendScaleData(type: Device.version().rawValue, size: self.image.size, time: timeInterval)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
