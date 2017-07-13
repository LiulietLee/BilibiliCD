//
//  ImageViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ImageViewController: UIViewController, NetworkingDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var adButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var pushButton: UIButton!
    
    var avNum: Int?
    fileprivate let netModel = NetworkingModel()
    fileprivate let dataModel = CoreDataModel()
    fileprivate var loadingView: LoadingView? = nil
    fileprivate var image = UIImage() {
        willSet {
            imageView.image = newValue
        }
    }
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-9289196786381154/6636960629"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        netModel.delegate = self
        if let num = avNum {
            self.title = "av" + String(num)
            netModel.getInfoFromAvNumber(avNum: num)
        } else {
            self.title = "No av number"
            print("No av number")
        }
        
        titleLabel.text = ""
        authorLabel.text = ""
        urlLabel.text = ""
        
        disableButtons()
        
        loadingView = LoadingView(frame: view.bounds)
        view.addSubview(loadingView!)
        view.bringSubview(toFront: loadingView!)
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIBarButtonItem) {
        saveImage()
    }
    
    @IBAction func adButtonTapped(_ sender: UIBarButtonItem) {
        let dialog = LLDialog()
        dialog.title = "广告显示设置"
        dialog.message = "屏幕下方的广告是我们维持服务的主要收入来源，但为了方便强迫症，您可以在这里自由选择是否显示广告，不需要额外付费。"
        dialog.setNegativeButton(withTitle: "关闭广告", target: self, action: #selector(disableToShowAd))
        dialog.setPositiveButton(withTitle: "显示广告", target: self, action: #selector(ableToShowAd))
        dialog.show()
    }
    
    @objc fileprivate func disableToShowAd() {
        if dataModel.readAdPremission()! {
            dataModel.setAdPremissionWith(false)
            let dialog = LLDialog()
            dialog.title = "广告已关闭"
            dialog.message = "从下次开始您将不会再看到广告。"
            dialog.setPositiveButton(withTitle: "嗯")
            dialog.show()
        }
    }
    
    @objc fileprivate func ableToShowAd() {
        if !dataModel.readAdPremission()! {
            dataModel.setAdPremissionWith(true)
            let dialog = LLDialog()
            dialog.title = "广告已显示"
            dialog.message = "从下次开始将会显示广告，谢谢您的支持\nε=ε=(ノ≧∇≦)ノ"
            dialog.setPositiveButton(withTitle: "嗯")
            dialog.show()
        }
    }
    
    fileprivate func getAd() {
        if let per = dataModel.readAdPremission() {
            if per {
                adBannerView.load(GADRequest())
            }
        } else {
            dataModel.setAdPremissionWith(true)
            adBannerView.load(GADRequest())
        }
    }
    
    @objc fileprivate func saveImage() {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(imageSavingFinished(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func imageSavingFinished(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
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
        adButton.isEnabled = true
    }
    
    fileprivate func disableButtons() {
        downloadButton.isEnabled = false
        pushButton.isEnabled = false
        adButton.isEnabled = false
    }
    
    func gotVideoInfo(info: Info) {        
        titleLabel.text = info.title!
        authorLabel.text = "UP主：" + info.author!
        urlLabel.text = info.imageUrl!
        urlLabel.sizeToFit()
    }
    
    func gotImage(image: UIImage) {
        imageView.image = image
        enableButtons()
        loadingView!.dismiss()
        getAd()
    }
    
    func connectError() {
        print("Cannot connect\n")
        titleLabel.text = "啊叻？"
        authorLabel.text = "连不上服务器了？"
        urlLabel.text = ""
        loadingView!.dismiss()
        imageView.image = UIImage(named: "error_image")
    }
    
    func cannotFindVideo() {
        titleLabel.text = "啊叻？"
        authorLabel.text = "视频不见了？"
        urlLabel.text = ""
        loadingView!.dismiss()
        imageView.image = UIImage(named: "novideo_image")
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        let height = view.bounds.size.height
        let y = height - bannerView.bounds.size.height
        bannerView.frame = CGRect(origin: CGPoint(x: 0, y: y), size: bannerView.bounds.size)
        view.addSubview(bannerView)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetailViewController
        vc.image = imageView.image!
    }

}
