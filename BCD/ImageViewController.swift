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
    let model = NetworkingModel()
    
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
        
        downloadButton.isEnabled = false
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
    }
    
    func connectError() {
        print("Cannot connect\n")
        titleLabel.text = "Cannot connect to server..."
    }
    
    func fetchingError() {
        print("Cannot fetch data\n")
        titleLabel.text = "Cannot fetch data from server..."
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
