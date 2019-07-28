//
//  EditController.swift
//  BCD
//
//  Created by Liuliet.Lee on 16/7/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit
import LLDialog

protocol EditControllerDelegate: class {
    func editFinished(username: String, content: String)
}

class EditController: UIViewController {
    
    enum EditModel {
        case comment
        case reply
    }

    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    weak var delegate: EditControllerDelegate? = nil
    var model = EditModel.comment
    var currentComment: Comment? = nil
    private var commentProvider = CommentProvider()
    
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
        if var username = usernameField.text,
            let content = textView.text,
            content != "" {
            
            if username == "" { username = "anonymous" }
            self.delegate?.editFinished(username: username, content: content)
            self.goBack()
        } else {
            LLDialog()
                .set(title: "注意")
                .set(message: "什么都不填是不行的呢")
                .setPositiveButton(withTitle: "好的")
                .show()
        }
    }
}
