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

        let attachments = (extensionContext?.inputItems.first as? NSExtensionItem)?
            .attachments?.filter { $0.isURL } ?? []
        if attachments.isEmpty {
            return cannotFindVideo()
        }
        for attachment in attachments {
            attachment.loadItem(forTypeIdentifier: kUTTypeURL as String) {
                (result, error) in
                let url = result as! URL
                self.url = url.absoluteString
                self.getCover()
            }
        }
    }
    
    private func getCover() {
        BilibiliCover.fromURL(url) { [weak self] (cover) in
            guard let cover = cover else {
                self?.disappear(because: "无法解析封面信息呢"); return
            }
            self?.cover = cover
            self?.coverInfoProvider.getCoverInfoBy(cover: cover) { info in
                if let info = info {
                    DispatchQueue.main.async {
                        self?.updateUIFrom(info: info)
                    }
                } else {
                    self?.cannotFindVideo()
                }
            }
        }
    }
    
    private func updateUIFrom(info: Info) {
        titleString = info.title
        author = info.author
        url = info.imageURL
        
        assetProvider.getImage(fromUrlPath: url) { [weak self] img in
            guard let self = self else { return }
            if let image = img {
                self.downloadImage(image)
                CacheManager().addNewDraft(
                    stringID: self.cover!.shortDescription,
                    title: self.titleString,
                    imageURL: URL(string: self.url)!,
                    author: self.author,
                    image: image
                )
                self.disappear(because: "封面已保存")
            } else {
                self.cannotFindVideo()
            }
        }
    }
    
    private func cannotFindVideo() {
        disappear(because: "找不到封面呢")
    }
    
    @IBAction func disappearButtonTapped() {
        extensionContext!.completeRequest(returningItems: nil)
    }
    
    private func disappear(because reason: String) {
        DispatchQueue.main.async { [weak self] in
            self?.message.text = reason
        }
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
