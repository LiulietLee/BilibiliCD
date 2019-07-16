//
//  EditController.swift
//  BCD
//
//  Created by Liuliet.Lee on 16/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit

protocol EditControllerDelegate: class {
    func editFinished(username: String, content: String)
}

class EditController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    weak var delegate: EditControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.becomeFirstResponder()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let height = keyboardRectangle.height
            bottomConstraint.constant = -height
            view.layoutIfNeeded()
        }
    }
    
    private func goBack() {
        usernameField.resignFirstResponder()
        textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonTapped() {
        goBack()
    }
    
    @IBAction func goButtonTapped() {
        delegate?.editFinished(username: usernameField.text!, content: textView.text)
        goBack()
    }

}
