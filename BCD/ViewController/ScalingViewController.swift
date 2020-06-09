
//
//  ScalingViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 28/10/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

protocol ScalingViewControllerDelegate: AnyObject {
    func scaleSucceed(scaledImage: UIImage)
}

class ScalingViewController: UIViewController {
    
    var image = UIImage()
    weak var delegate: ScalingViewControllerDelegate?
    var protoc = [0, 2, 1] // protoc = [次元, 降噪, 放大]
    var model: Model?
    
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
        if let model = modelSwitch(protoc: protoc) {
            self.model = model
            scaleImage()
        } else {
            self.delegate?.scaleSucceed(scaledImage: image)
            self.dismiss(animated: true)
        }
    }
    
    private func scaleImage() {
        let start = DispatchTime.now()
        let background = DispatchQueue(label: "background")
        
        background.async { [weak self] in
            guard let self = self else { return }
        
            let image_scale = Waifu2x.run(self.image, model: self.model!)?.reload()
            let end = DispatchTime.now()
            let nanotime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(nanotime) / 1_000_000_000
            print("time: \(timeInterval)")
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.scaleSucceed(scaledImage: image_scale!)
                self?.dismiss(animated: true)
            }
        }
    }
}

extension ScalingViewController {
    func modelSwitch(protoc: [Int]) -> Model? {
        if protoc[0] == 0 {     // 二次元
            if protoc[2] == 0 { // 不放大
                switch protoc[1] {
                case 0:     return nil
                case 1:     return .anime_noise0
                case 2:     return .anime_noise1
                case 3:     return .anime_noise2
                default:    return .anime_noise3
                }
            } else {            // 放大
                switch protoc[1] {
                case 0:     return .anime_scale2x
                case 1:     return .anime_noise0_scale2x
                case 2:     return .anime_noise1_scale2x
                case 3:     return .anime_noise2_scale2x
                default:    return .anime_noise3_scale2x
                }
            }
        } else {                // 三次元
            if protoc[2] == 0 { // 不放大
                switch protoc[1] {
                case 0:     return nil
                case 1:     return .photo_noise0
                case 2:     return .photo_noise1
                case 3:     return .photo_noise2
                default:    return .photo_noise3
                }
            } else {            // 放大
                switch protoc[1] {
                case 0:     return .photo_scale2x
                case 1:     return .photo_noise0_scale2x
                case 2:     return .photo_noise1_scale2x
                case 3:     return .photo_noise2_scale2x
                default:    return .photo_noise3_scale2x
                }
            }
        }
    }
}

extension UIImage {
    
    /// Workaround: Apply two ML filters sequently will break the image
    ///
    /// - Returns: the reloaded image
    public func reload(jpg: Bool = false, quality: CGFloat = 0.9) -> UIImage? {
        var tmpfile: URL
        if jpg {
            tmpfile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.jpg")
        } else {
            tmpfile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.png")
        }
        let fm = FileManager.default
        if fm.fileExists(atPath: tmpfile.path) {
            try? fm.removeItem(at: tmpfile)
        }
        if jpg {
            try! self.jpegData(compressionQuality: quality)?.write(to: tmpfile)
        } else {
            try! self.pngData()?.write(to: tmpfile)
        }
        let img = UIImage(contentsOfFile: tmpfile.path)
        return img
    }
    
}
