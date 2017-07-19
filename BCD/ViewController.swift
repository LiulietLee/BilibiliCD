//
//  ViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var avLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var menu: UIBarButtonItem!
    fileprivate var timer = Timer()
    fileprivate var repeatTappingTime = 0
    fileprivate var avNumber = 0 {
        willSet {
            avLabel.text = "av" + String(newValue)
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
                                               name: NSNotification.Name(rawValue: notiKey),
                                               object: nil)
    }

    @objc fileprivate func getURLFromPasteboard() {
        if let urlString = UIPasteboard.general.string {
            let tempArray = Array(urlString.characters)
            var avNum = 0
            var isAvNum = false
            for i in 0..<tempArray.count {
                let j = tempArray.count - i - 1
                if let singleNum = Int(String(tempArray[j])) {
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
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        goButton.isEnabled = false
        menu.target = revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        getURLFromPasteboard()
    }
    
    @IBAction func numberButtonTapped(_ sender: UIButton) {
        let new = sender.title(for: .normal)!
        avNumber = avNumber * 10 + Int(new)!
    }
    
    @IBAction func backspaceButtonTapped() {
        avNumber /= 10
        
        if repeatTappingTime == 0 {
            timer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false, block: { (t) in
                self.repeatTappingTime = 0
            })
        } else if repeatTappingTime >= 2 {
            avNumber = 0
        }
        
        repeatTappingTime += 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ImageViewController {
            vc.avNum = avNumber
        }
    }
    
}

