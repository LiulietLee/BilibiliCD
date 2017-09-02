//
//  ViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import SWRevealViewController

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var avLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var menu: UIBarButtonItem!
    fileprivate var repeatTappingTime = 0
    fileprivate var avNumber = 0 {
        willSet {
            avLabel.text = "av\(newValue)"
            if newValue == 0 {
                goButton.isEnabled = false
            } else {
                goButton.isEnabled = true
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
        if let urlString = UIPasteboard.general.string {
            let tempArray = Array(urlString.characters)
            var avNum = 0
            var isAvNum = false
            for i in 0..<tempArray.count {
                let j = tempArray.count - i - 1
                if let singleNum = Int("\(tempArray[j])") {
                    var num = singleNum
                    num *= Int(NSDecimalNumber(decimal: pow(10, i)))
                    avNum += num
                } else if tempArray[j] == "/" {
                    continue
                } else if tempArray[j] == "v" && j >= 1 {
                    if tempArray[j - 1] == "a" {
                        isAvNum = true
                        break
                    }
                }
            }
            
            if isAvNum {
                avNumber = avNum
                isShowingImage = true
                let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "image controller") as! ImageViewController
                nextViewController.avNum = avNumber
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
    }
    
    @IBAction func numberButtonTapped(_ sender: UIButton) {
        let new = sender.currentTitle!
        avNumber = avNumber * 10 + Int(new)!
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
        (segue.destination as? ImageViewController)?.avNum = avNumber
    }
    
}

