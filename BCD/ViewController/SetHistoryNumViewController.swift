//
//  SetHistoryNumViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 22/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

protocol SetHistoryNumDelegate {
    func historyNumLimitChanged()
}

class SetHistoryNumViewController: UIViewController {

    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var delegate: SetHistoryNumDelegate?
    var isShowingFullHistory = false

    private let settingManager = SettingManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let num = settingManager.historyItemLimit {
            numberField.text = "\(num)"
        }
        
        numberField.becomeFirstResponder()
        numberField.layer.borderColor = UIColor.clear.cgColor
        
        changeColor(to: isShowingFullHistory ? .black : .tianyiBlue)
    }
    
    private func changeColor(to color: UIColor) {
        cancelButton.setTitleColor(color, for: .normal)
        saveButton.setTitleColor(color, for: .normal)
        numberField.textColor = color
        numberField.tintColor = color
    }
    
    private func goBack() {
        numberField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped() {
        if let text = numberField.text
            , let num = Int(text) {
            settingManager.historyItemLimit = max(min(num, 1000), 0)
            delegate?.historyNumLimitChanged()
        }
        goBack()
    }

    @IBAction func cancelButtonTapped() {
        goBack()
    }

}
