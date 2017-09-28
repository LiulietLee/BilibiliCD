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
    fileprivate let dataModel = CoreDataModel()
    
    var delegate: SetHistoryNumDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let num = dataModel.historyNum {
            numberField.text = "\(num)"
        }
        
        numberField.becomeFirstResponder()
        numberField.layer.borderColor = UIColor.clear.cgColor
    }
    
    fileprivate func goBack() {
        numberField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped() {
        if let text = numberField.text {
            if let num = Int(text) {
                dataModel.historyNum = max(min(num, 1000), 0)
                if let del = delegate {
                    del.historyNumLimitChanged()
                }
            }
        }
        goBack()
    }

    @IBAction func cancelButtonTapped() {
        goBack()
    }

}
