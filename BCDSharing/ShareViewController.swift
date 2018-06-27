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

class ShareViewController: UIViewController, VideoCoverDelegate {

    private var url = ""
    private var author = ""
    private var titleString = ""
    private var cover: BilibiliCover?
    private let netModel = NetworkingModel()
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var frameView: UIView!
    
    override func viewDidLoad() {
        frameView.layer.masksToBounds = true
        frameView.layer.cornerRadius = 10.0
        netModel.delegateForVideo = self
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        let contentTypeURL = kUTTypeURL as String
        for attachment in extensionItem.attachments as! [NSItemProvider] {
            if attachment.isURL {
                attachment.loadItem(forTypeIdentifier: contentTypeURL, options: [:]) { (result, error) in
                    let url = result as! URL
                    self.url = url.absoluteString
                    self.getCover()
                }
            }
        }
    }
    
    private func getCover() {
        guard let cover = BilibiliCover.fromURL(url) else { return }
        self.cover = cover
        netModel.getCoverInfo(byType: cover.type, andNID: cover.number)
    }
    
    func gotVideoInfo(_ info: Info) {
        titleString = info.title
        author = info.author
    }
    
    func gotImage(_ image: Image) {
        downloadImage(image)
        CacheManager.addNewDraft(
            stringID: cover!.shortDescription,
            title: titleString,
            imageURL: URL(string: url)!,
            author: author,
            image: image
        )
        message.text = "封面已保存"
        disappear()
    }
    
    func connectError() {
        message.text = "连接不到服务器呢"
        disappear()
    }
    
    func cannotFindVideo() {
        message.text = "找不到封面呢"
        disappear()
    }
    
    @IBAction func disappearButtonTapped() {
        extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    private func disappear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            self.disappearButtonTapped()
        }
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
