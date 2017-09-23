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
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    private var coverType = "video"
    private var number = 10086
    private let netModel = NetworkingModel()
    private var loadingView: LoadingView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        netModel.delegateForVideo = self
        
        loadingView = LoadingView(frame: view.bounds)
        view.addSubview(loadingView)
        view.bringSubview(toFront: loadingView)
        
        scanPasteBoard()
    }
    
    private func scanPasteBoard() {
        if let urlString = UIPasteboard.general.string {
            let tempArray = Array(urlString.characters)
            var avNum = 0
            var isAvNum = false, isLvNum = false
            for i in 0..<tempArray.count {
                let j = tempArray.count - i - 1
                if let singleNum = Int("\(tempArray[j])") {
                    var num = singleNum
                    num *= Int(truncating: NSDecimalNumber(decimal: pow(10, i)))
                    avNum += num
                } else if tempArray[j] == "/" {
                    if j > 22 {
                        let index = urlString.index(urlString.startIndex, offsetBy: 21)
                        // print(urlString[..<index])
                        if urlString[..<index] == "https://live.bilibili" {
                            isLvNum = true
                            break
                        }
                    }
                    continue
                } else if tempArray[j] == "v" && j >= 1 {
                    if tempArray[j - 1] == "a" {
                        isAvNum = true
                        break
                    }
                } else { break }
            }
            
            if isAvNum || isLvNum {
                number = avNum
                if isLvNum {
                    numberLabel.text = "lv\(number)"
                    coverType = "live"
                } else {
                    numberLabel.text = "av\(number)"
                }
                fetchCover()
            }
        }
    }
    
    private func fetchCover() {
        if coverType == "live" {
            netModel.getLiveInfo(lvNum: number)
        } else {
            netModel.getInfoFromAvNumber(avNum: number)
        }
    }
    
    func gotVideoInfo(_ info: Info) {
        titleLabel.text = info.title
    }
    func gotImage(_ image: UIImage) {
        imageView.image = image
        loadingView.dismiss()
        downloadButton.isEnabled = true
    }
    func connectError() {
        loadingView.dismiss()
    }
    func cannotFindVideo() {
        loadingView.dismiss()
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
            print("yes!")
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
