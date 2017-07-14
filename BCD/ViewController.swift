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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goButton.isEnabled = false
        menu.target = revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
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

