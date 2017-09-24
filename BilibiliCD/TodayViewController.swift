//
//  TodayViewController.swift
//  BilibiliCD
//
//  Created by Liuliet.Lee on 23/9/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, VideoCoverDelegate {
    
    @IBOutlet weak var loadingText: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    private var coverType = BilibiliCover.Category.video
    private var number = 10086
    private let netModel = NetworkingModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        netModel.delegateForVideo = self
        downloadButton.setTitleColor(.white, for: .normal)
        scanPasteBoard()
    }
    
    private func scanPasteBoard() {
        if let cover = BilibiliCover.fromPasteboard() {
            number = cover.number
            coverType = cover.type
            numberLabel.text = cover.shortDescription
            fetchCover()
        }
    }
    
    private func fetchCover() {
        switch coverType {
        case .live:  netModel.getLiveInfo(lvNum: number)
        case .video: netModel.getInfoFromAvNumber(avNum: number)
        }
    }
    
    func gotVideoInfo(_ info: Info) {
        titleLabel.text = info.title
    }
    
    func gotImage(_ image: UIImage) {
        imageView.image = image
        downloadButton.isEnabled = true
        loadingText.removeFromSuperview()
    }
    
    func connectError() {
        numberLabel.text = "啊叻？！连不上服务器了？"
        titleLabel.text = "原因大概是我们的服(V)务(P)器(S)炸了"
        imageView.image = #imageLiteral(resourceName: "error_image")
        loadingText.removeFromSuperview()
    }
    
    func cannotFindVideo() {
        numberLabel.text = "啊叻？！视频不见了？"
        titleLabel.text = "目前还抓不到「会员的世界」的封面哦"
        imageView.image = #imageLiteral(resourceName: "novideo_image")
        loadingText.removeFromSuperview()
    }
    
    @IBAction func downloadImage() {
        saveImage()
    }
    
    @objc fileprivate func saveImage() {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(imageSavingFinished(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func imageSavingFinished(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error)
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.downloadButton.backgroundColor = .white
            }, completion: { (finished) in
                if finished {
                    UIView.animate(withDuration: 0.3) {
                        self.downloadButton.backgroundColor = .clear
                    }
                }
            })
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
