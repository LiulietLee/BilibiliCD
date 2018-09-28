//
//  ImageViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import ViewAnimator
import MobileCoreServices
import MaterialKit

class ImageViewController: UIViewController, VideoCoverDelegate, Waifu2xDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var pushButton: UIButton!
    /// Should be disabled for GIF.
    @IBOutlet weak var scaleButton: UIBarButtonItem!
    @IBOutlet weak var separator: UIProgressView!
    @IBOutlet weak var citationStyleControl: UISegmentedControl!
    @IBOutlet weak var citationTextView: UITextView!
    @IBOutlet weak var copyButton: UIButton!

    @IBOutlet var labels: [UILabel]!

    private let coverInfoProvider = CoverInfoProvider()
    private let assetProvider = AssetProvider()

    var cover: BilibiliCover?
    var itemFromHistory: History?
    private let manager = HistoryManager()
    private var loadingView: LoadingView!
    private var reference: (info: Info?, style: CitationStyle) = (nil, .apa) {
        didSet {
            guard let info = reference.info else { return }
            citationTextView?.attributedText = info.citation(ofStyle: reference.style)
            titleLabel?.text = info.title
            authorLabel?.text = "UP主：\(info.author)"
            urlLabel.text = "URL：\(info.imageURL)"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isShowingImage = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(goBackIfNeeded),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    @objc private func goBackIfNeeded() {
        if itemFromHistory != nil, itemFromHistory!.isHidden {
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main") as! MainViewController
            
            show(nextViewController, sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isShowingImage = true
        coverInfoProvider.delegateForVideo = self
        if let cover = cover {
            title = cover.shortDescription
            if itemFromHistory == nil {
                coverInfoProvider.getCoverInfo(byType: cover.type, andNID: cover.number)
            }
        } else {
            title = "No av number"
            print("No av number")
        }

        if let item = itemFromHistory {
            reference.info = Info(stringID: item.av!, author: item.up!, title: item.title!, imageURL: item.url!)
            imageView.image = item.uiImage

            changeTextColor(to: item.isHidden ? .black : .tianyiBlue)

            animateView()
        } else {
            titleLabel.text = ""
            authorLabel.text = ""
            urlLabel.text = ""

            disableButtons()

            loadingView = LoadingView(frame: view.bounds)
            view.addSubview(loadingView)
            view.bringSubviewToFront(loadingView)
        }
    }
    
    private func animateView() {
        let type = AnimationType.from(direction: .right, offset: ViewAnimatorConfig.offset)
        scrollView.doAnimation(type: type)
    }
    
    private func changeTextColor(to color: UIColor) {
        labels?.forEach { $0.textColor = color }
        citationStyleControl?.tintColor = color
        separator?.progressTintColor = color
        copyButton?.tintColor = color
        navigationController?.navigationBar.barTintColor = color
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIBarButtonItem) {
        saveImage()
    }
    
    @IBAction func titleButtonTapped() {
        if let cover = cover {
            UIApplication.shared.open(cover.url)
        }
    }

    @objc private func saveImage() {
        let image: Image
        guard let item = itemFromHistory
            , let url = item.url
            , let uiImage = imageView?.image
            , let data = item.origin?.image
            else {
                return imageSaved(successfully: false, error: nil)
        }
        if url.isGIF {
            image = .gif(uiImage, data: data)
        } else {
            image = .normal(uiImage)
        }
        ImageSaver.saveImage(image, completionHandler: imageSaved, alternateHandler: #selector(imageSavingFinished(_:didFinishSavingWithError:contextInfo:)))
    }
    
    @objc func imageSavingFinished(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        imageSaved(successfully: error == nil, error: error)
    }

    private func imageSaved(successfully: Bool, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let dialog = LLDialog()
            if !successfully || error != nil {
                dialog.title = "啊叻？！"
                dialog.message = "保存出错了Σ( ￣□￣||)"
                dialog.setNegativeButton(withTitle: "好吧")
                dialog.setPositiveButton(withTitle: "再试一次", target: self, action: #selector(self.saveImage))
                dialog.show()
                print(error ?? "Unknown error")
            } else {
                dialog.title = "保存成功！"
                dialog.message = "封面被成功保存(〜￣△￣)〜"
                dialog.setPositiveButton(withTitle: "OK")
                dialog.show()
            }
        }
    }
    
    private func enableButtons() {
        downloadButton.isEnabled = true
        scaleButton.isEnabled = !reference.info!.imageURL.isGIF
        pushButton.isEnabled = true
    }
    
    private func disableButtons() {
        downloadButton.isEnabled = false
        scaleButton.isEnabled = false
        pushButton.isEnabled = false
    }
    
    func gotVideoInfo(_ info: Info) {
        reference.info = info
        
        assetProvider.getImage(fromUrlPath: info.imageURL) { img in
            if let image = img {
                DispatchQueue.main.async { [weak self] in
                    self?.imageView.image = image.uiImage
                    switch image {
                    case .gif: self?.scaleButton.isEnabled = false
                    case .normal: self?.scaleButton.isEnabled = true
                    }
                    self?.enableButtons()
                    self?.loadingView.dismiss()
                    self?.animateView()
                    self?.addItemToDB(image: image)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.cannotFindVideo()
                }
            }
        }
    }
    
    func scaleSucceed(scaledImage: UIImage) {
        imageView.image = scaledImage
        manager.changeOriginCover(of: itemFromHistory!, image: scaledImage)
        scaleButton.isEnabled = false
        
        let dialog = LLDialog()
        dialog.title = "(｡･ω･｡)"
        dialog.message = "放大完成~"
        dialog.setPositiveButton(withTitle: "嗯")
        dialog.show()
    }
    
    private func addItemToDB(image: Image) {
        DispatchQueue.global(qos: .userInteractive).async {
            [info = reference.info!, id = cover!.shortDescription] in
            self.itemFromHistory = self.manager.addNewHistory(
                av: id, image: image, title: info.title, up: info.author, url: info.imageURL
            )
        }
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

    @IBAction func changeCitationFormat(_ sender: UISegmentedControl) {
        reference.style = CitationStyle(rawValue: sender.selectedSegmentIndex)!
    }

    lazy var generator: UINotificationFeedbackGenerator = .init()

    @IBAction func copyToPasteBoard() {
        copyButton.resignFirstResponder()
        do {
            guard let citation = citationTextView.attributedText else { throw NSError() }
            let range = NSRange(location: 0, length: citation.length)
            let rtf = try citation.data(from: range, documentAttributes:
                [.documentType : NSAttributedString.DocumentType.rtf])
            UIPasteboard.general.items = [
                [
                    kUTTypeRTF as String: String(data: rtf, encoding: .utf8)!,
                    kUTTypeUTF8PlainText as String: citation.string
                ]
            ]
            generator.notificationOccurred(.success)
            MKSnackbar(withTitle: "Copied", withDuration: nil, withTitleColor: nil, withActionButtonTitle: nil, withActionButtonColor: nil).show()
        } catch {
            generator.notificationOccurred(.error)
            MKSnackbar(withTitle: "Failed to Copy", withDuration: nil, withTitleColor: nil, withActionButtonTitle: nil, withActionButtonColor: nil).show()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem

        if let vc = segue.destination as? DetailViewController {
            vc.image = imageView.image
            vc.isHidden = itemFromHistory?.isHidden
        } else if let vc = segue.destination as? Waifu2xViewController {
            vc.originImage = imageView.image
            vc.delegate = self
        }
    }
}
