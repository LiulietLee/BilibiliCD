//
//  ViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var menu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goButton.isEnabled = false
        textField.delegate = self
        textField.becomeFirstResponder()
        menu.target = self.revealViewController()
        menu.action = #selector(revealViewController().revealToggle(_:))
        self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text == "" && string == "0" {
            return false
        }
        
        if textField.text?.characters.count == 1 && string == "" {
            goButton.isEnabled = false
        } else {
            goButton.isEnabled = true
        }
        return true
    }
}

