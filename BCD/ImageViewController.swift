//
//  ImageViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import ViewAnimator

class ImageViewController: UIViewController, VideoCoverDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var pushButton: UIButton!
    
    var cover: BilibiliCover?
    var itemFromHistory: History?
    fileprivate let netModel = NetworkingModel()
    fileprivate let dataModel = CoreDataModel()
    fileprivate var loadingView: LoadingView!
    fileprivate let nudity = Nudity()
    fileprivate var image = UIImage() {
        willSet {
            imageView.image = newValue
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isShowingImage = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isShowingImage = true
        netModel.delegateForVideo = self
        if let cover = cover {
            title = cover.shortDescription
            if itemFromHistory == nil {
                switch cover.type {
                case .video:   netModel.getInfoFromAvNumber(avNum: cover.number)
                case .live:    netModel.getLiveInfo(lvNum: cover.number)
                case .article: netModel.getArticleInfo(cvNum: cover.number)
                }
            }
        } else {
            title = "No av number"
            print("No av number")
        }
        
        if itemFromHistory == nil {
            titleLabel.text = ""
            authorLabel.text = ""
            urlLabel.text = ""
            
            disableButtons()
            
            loadingView = LoadingView(frame: view.bounds)
            view.addSubview(loadingView)
            view.bringSubview(toFront: loadingView)
        } else {
            titleLabel.text = itemFromHistory!.title!
            authorLabel.text = itemFromHistory!.up!
            urlLabel.text = itemFromHistory!.url!
            
            if let originCoverData = itemFromHistory?.origin?.image {
                imageView.image = UIImage(data: originCoverData)
            } else {
                imageView.image = UIImage(data: itemFromHistory!.image! as Data)
            }
            
            if itemFromHistory!.isHidden {
                changeTextColor(to: .black)
            } else {
                changeTextColor(to: .tianyiBlue)
            }
            
            animateView()
            dataModel.isNeedHid(imageView.image!)
        }
    }
    
    fileprivate func animateView() {
        let type = AnimationType.from(direction: .right, offset: ViewAnimatorConfig.offset)
        view.doAnimation(type: type)
    }
    
    fileprivate func changeTextColor(to color: UIColor) {
        titleLabel.textColor = color
        authorLabel.textColor = color
        urlLabel.textColor = color
        self.navigationController?.navigationBar.barTintColor = color
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIBarButtonItem) {
        saveImage()
    }
    
    @IBAction func titleButtonTapped() {
        if let cover = cover {
            UIApplication.shared.open(cover.url)
        }
    }
    
    @objc fileprivate func saveImage() {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(imageSavingFinished(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func imageSavingFinished(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
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
    
    func gotVideoInfo(_ info: Info) {
        titleLabel.text = info.title
        authorLabel.text = "UP主：\(info.author)"
        urlLabel.text = "URL：\(info.imageURL)"
        urlLabel.sizeToFit()
        titleLabel.sizeToFit()
        authorLabel.sizeToFit()
    }
    
    func gotImage(_ image: UIImage) {
        imageView.image = image
        enableButtons()
        loadingView.dismiss()
        animateView()
        DispatchQueue.global(qos: .userInteractive).async {
            self.addItemToDB()
        }
    }
    
    fileprivate func addItemToDB() {
        dataModel.addNewHistory(av: cover!.shortDescription,
            date: Date(),
            image: imageView.image!,
            title: titleLabel.text!,
            up: authorLabel.text!,
            url: urlLabel.text!)        
    }
    
    func connectError() {
        print("Cannot connect\n")
        titleLabel.text = "啊叻？"
        authorLabel.text = "连不上服务器了？"
        urlLabel.text = "提示：如果一直提示这个可能是我们的服(V)务(P)器(S)炸了，你可以去「关于我们」页面找我们反映情况哦~"
        loadingView.dismiss()
        imageView.image = #imageLiteral(resourceName: "error_image")
    }
    
    func cannotFindVideo() {
        titleLabel.text = "啊叻？"
        authorLabel.text = "视频不见了？"
        urlLabel.text = "emmmmmmmm... 大概这个视频是真的不见了吧 (\"▔□▔)/"
        loadingView.dismiss()
        imageView.image = #imageLiteral(resourceName: "novideo_image")
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetailViewController
        vc.image = imageView.image!
    }
    
}
