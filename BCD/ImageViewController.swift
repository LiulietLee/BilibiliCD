//
//  ImageViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController,NetworkingDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var pushButton: UIButton!
    
    var avNum: Int?
    fileprivate let model = NetworkingModel()
    fileprivate let loadingView = LoadingView()
    fileprivate var image = UIImage() {
        willSet {
            imageView.image = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.delegate = self
        if let num = avNum {
            self.title = String(num)
            model.getInfoFromAvNumber(avNum: num)
        } else {
            self.title = "No av number"
            print("No av number")
        }
        
        titleLabel.text = ""
        authorLabel.text = ""
        urlLabel.text = ""
        
        disableButtons()
        
        loadingView.frame = view.bounds
        view.addSubview(loadingView)
        view.bringSubview(toFront: loadingView)
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIBarButtonItem) {
        saveImage()
    }
    
    @objc fileprivate func saveImage() {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSavingFinished(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc fileprivate func imageSavingFinished(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let dialog = LLDialog()
        if let error = error {
            dialog.title = "啊叻？！"
            dialog.message = "下载出错了Σ( ￣□￣||)"
            dialog.setNegativeButton(withTitle: "好吧")
            dialog.setPositiveButton(withTitle: "再试一次", target: self, action: #selector(saveImage))
            dialog.show()
            print(error)
        } else {
            dialog.title = "保存成功！"
            dialog.message = "封面被成功保存(〜￣△￣)〜"
            dialog.setPositiveButton(withTitle: "OK")
            dialog.show()
        }
    }
    
    fileprivate func enableButtons() {
        downloadButton.isEnabled = true
        pushButton.isEnabled = true
    }
    
    fileprivate func disableButtons() {
        downloadButton.isEnabled = false
        pushButton.isEnabled = false
    }
    
    func gotVideoInfo(info: Info) {
        enableButtons()
        
        titleLabel.text = info.title!
        authorLabel.text = info.author!
        urlLabel.text = info.imageUrl!
    }
    
    func gotImage(image: UIImage) {
        imageView.image = image
        enableButtons()
        loadingView.dismiss()
    }
    
    func connectError() {
        print("Cannot connect\n")
        titleLabel.text = "啊叻？"
        authorLabel.text = "视频不见了？"
        urlLabel.text = ""
        loadingView.dismiss()
        imageView.image = UIImage(named: "error_image")
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
            let vc = segue.destination as! DetailViewController
            vc.image = image
        }
    }

}
