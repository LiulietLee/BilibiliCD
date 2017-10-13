//
//  MainViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import SWRevealViewController

class MainViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var avLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var menu: UIBarButtonItem!
    fileprivate var repeatTappingTime = 0
    fileprivate var dataModel = CoreDataModel()
    var cover = BilibiliCover(number: 0, type: .video) {
        didSet {
            avLabel?.text = cover.shortDescription
            if cover.number == 0 {
                goButton.isEnabled = false
                if cover.type != .video {
                    cover = BilibiliCover(number: 0, type: .video)
                }
            } else {
                goButton.isEnabled = true
            }
        }
    }
    private var avNumber: UInt64 {
        get { return cover.number }
        set {
            if newValue > avNumber {
                cover.number = newValue
            } else if newValue < avNumber {
                // Overflow happend
                cover.number = 0
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getURLFromPasteboard),
                                               name: .BCD,
                                               object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func getURLFromPasteboard() {
        if isShowingImage { return }
        if let newCover = BilibiliCover.fromPasteboard() {
            self.cover = newCover
            if !dataModel.isExistInHistory(cover: newCover) {
                isShowingImage = true
                let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "image controller") as! ImageViewController
                
                nextViewController.cover = newCover
                show(nextViewController, sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isShowingImage = false
        goButton.isEnabled = false
        menu.target = revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        getURLFromPasteboard()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func numberButtonTapped(_ sender: UIButton) {
        let new = sender.currentTitle!
        avNumber = avNumber &* 10 &+ UInt64(new)!
    }
    
    @IBAction func backspaceButtonTapped() {
        avNumber /= 10
        
        if repeatTappingTime == 0 {
            _ = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { _ in
                self.repeatTappingTime = 0
            }
        } else if repeatTappingTime >= 2 {
            avNumber = 0
        }
        
        repeatTappingTime += 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? ImageViewController)?.cover = cover
    }
    
}
