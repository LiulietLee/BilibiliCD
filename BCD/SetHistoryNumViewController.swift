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
        
        if let num = dataModel.getHistoryNum() {
            numberField.text = String(num)
        }
        
        numberField.becomeFirstResponder()
        numberField.layer.borderColor = UIColor.clear.cgColor
    }
    
    fileprivate func goBack() {
        numberField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped() {
        if let text = numberField.text {
            if let num = Int(text) {
                dataModel.setHistory(num: num)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
