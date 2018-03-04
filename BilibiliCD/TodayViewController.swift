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
    private var cover: BilibiliCover?
    private var number: UInt64 = 10086
    private let netModel = NetworkingModel()
    private let dataModel = CoreDataModel()
    private var upName = ""
    private var urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        netModel.delegateForVideo = self
        downloadButton.setTitleColor(.white, for: .normal)
        scanPasteBoard()
    }
    
    private func scanPasteBoard() {
        if let cover = BilibiliCover.fromPasteboard(), cover != self.cover {
            if dataModel.isExistInHistory(cover: cover) != nil {
                loadingText.text = "这个封面似乎已经\n在历史记录里了呢"
                return
            }
            self.cover = cover
            number = cover.number
            numberLabel.text = cover.shortDescription

            switch cover.type {
            case .live:    netModel.getLiveInfo(lvNum: number)
            case .video:   netModel.getInfoFromAvNumber(avNum: number)
            case .article: netModel.getArticleInfo(cvNum: number)
            }
        } else {
            loadingText.text = "今天真是寂寞如雪哦"
        }
    }
    
    func gotVideoInfo(_ info: Info) {
        titleLabel.text = info.title
        upName = "UP主：\(info.author)"
        urlString = "URL：\(info.imageURL)"
    }
    
    func gotImage(_ image: UIImage) {
        imageView.image = image
        downloadButton.isEnabled = true
        loadingText.removeFromSuperview()
        
        _ = dataModel.addNewHistory(av: cover!.shortDescription,
                                image: imageView.image!,
                                title: titleLabel.text!,
                                up: upName,
                                url: urlString)
    }
    
    func connectError() {
        numberLabel.text = "啊叻？！连不上服务器了？"
        titleLabel.text = "原因大概是我们的服(V)务(P)器(S)炸了"
        imageView.image = #imageLiteral(resourceName: "error_image")
        loadingText.removeFromSuperview()
    }
    
    func cannotFindVideo() {
        numberLabel.text = "啊叻？！视频不见了？"
        titleLabel.text = "大概这个视频是真的不见了吧"
        imageView.image = #imageLiteral(resourceName: "novideo_image")
        loadingText.removeFromSuperview()
    }
    
    @IBAction func downloadImage() {
        saveImage()
    }
    
    @objc private func saveImage() {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(imageSavingFinished(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func imageSavingFinished(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error)
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.downloadButton.backgroundColor = .white
            }, completion: { finished in
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
        scanPasteBoard()
        completionHandler(NCUpdateResult.newData)
    }
    
}
