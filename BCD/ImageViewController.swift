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

    var avNum: Int?
    fileprivate let model = NetworkingModel()
    fileprivate let loadingView = LoadingView()
    
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
        
        downloadButton.isEnabled = false
        
        loadingView.frame = view.bounds
        view.addSubview(loadingView)
        view.bringSubview(toFront: loadingView)
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIBarButtonItem) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func gotVideoInfo(info: Info) {
        downloadButton.isEnabled = true
        
        titleLabel.text = info.title!
        authorLabel.text = info.author!
        urlLabel.text = info.imageUrl!
    }
    
    func gotImage(image: UIImage) {
        imageView.image = image
        downloadButton.isEnabled = true
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
        
    }

}
