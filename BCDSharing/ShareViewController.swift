//
//  ShareViewController.swift
//  BCDSharing
//
//  Created by Liuliet.Lee on 22/6/2018.
//  Copyright © 2018 Liuliet.Lee. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: UIViewController {

    private var url = ""
    private var author = ""
    private var titleString = ""
    private var cover: BilibiliCover?
    
    private let coverInfoProvider = CoverInfoProvider()
    private let assetProvider = AssetProvider()
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var frameView: UIView!
    
    override func viewDidLoad() {
        frameView.layer.masksToBounds = true
        frameView.layer.cornerRadius = 10.0
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        let contentTypeURL = kUTTypeURL as String
        for attachment in extensionItem.attachments! where attachment.isURL {
            attachment.loadItem(forTypeIdentifier: contentTypeURL) {
                (result, error) in
                let url = result as! URL
                self.url = url.absoluteString
                self.getCover()
            }
        }
    }
    
    private func getCover() {
        BilibiliCover.fromPasteboard { (newCover) in
            if let cover = newCover {
                self.cover = cover
                self.coverInfoProvider.getCoverInfoBy(cover: cover) { info in
                    DispatchQueue.main.async { [weak self] in
                        if let info = info {
                            self?.updateUIFrom(info: info)
                        } else {
                            self?.cannotFindVideo()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.message.text = "无法解析封面信息呢"
                    self?.disappear()
                }
            }
        }

    }
    
    private func updateUIFrom(info: Info) {
        titleString = info.title
        author = info.author
        url = info.imageURL
        
        assetProvider.getImage(fromUrlPath: url) { img in
            if let image = img {
                self.downloadImage(image)
                CacheManager().addNewDraft(
                    stringID: self.cover!.shortDescription,
                    title: self.titleString,
                    imageURL: URL(string: self.url)!,
                    author: self.author,
                    image: image
                )
                DispatchQueue.main.async { [weak self] in
                    self?.message.text = "封面已保存"
                    self?.disappear()
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.cannotFindVideo()
                }
            }
        }
    }
    
    private func cannotFindVideo() {
        message.text = "找不到封面呢"
        disappear()
    }
    
    @IBAction func disappearButtonTapped() {
        extensionContext!.completeRequest(returningItems: nil)
    }
    
    private func disappear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1),
                                      execute: disappearButtonTapped)
    }
    
    private func downloadImage(_ image: Image) {
        ImageSaver.saveImage(image)
    }
}

extension NSItemProvider {
    var isURL: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeURL as String)
    }
}
