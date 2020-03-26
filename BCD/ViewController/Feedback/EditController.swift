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
        view.tintColor = UIColor.systemOrange
        
        usernameField.text = UserDefaults.standard.string(forKey: "feedbackUsername")
        textView.text = UserDefaults.standard.string(forKey: "feedbackContent")
        
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
            bottomConstraint.constant = height
            view.layoutIfNeeded()
        }
    }
    
    private func goBack() {
        UserDefaults.standard.set(usernameField.text!, forKey: "feedbackUsername")
        usernameField.resignFirstResponder()
        textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonTapped() {
        UserDefaults.standard.set(textView.text!, forKey: "feedbackContent")
        goBack()
    }
    
    private var isUsernameFirst = false

    @objc private func showKeyboard() {
        if isUsernameFirst {
            usernameField.becomeFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }
    }
    
    private func showTip(message str: String) {
        isUsernameFirst = usernameField.isFirstResponder
        usernameField.resignFirstResponder()
        textView.resignFirstResponder()
        LLDialog()
            .set(message: str)
            .setPositiveButton(withTitle: "嗯", target: self, action: #selector(showKeyboard))
            .show()
    }
    
    @IBAction func goButtonTapped() {
        if var username = usernameField.text,
            var content = textView.text {
            
            username = username.trimmingCharacters(in: .whitespacesAndNewlines)
            content = content.trimmingCharacters(in: .whitespacesAndNewlines)
            var tempString = content.replacingOccurrences(of: "\n\n\n", with: "\n\n")
            while tempString != content {
                content = tempString
                tempString = content.replacingOccurrences(of: "\n\n\n", with: "\n\n")
            }
            
            if content == "" {
                showTip(message: "什么都不填是不行的呢")
                return
            } else if content.count > 450 {
                showTip(message: "正文最长可以有 450 个字哦。")
                return
            } else if username.hasSpecialCharacters() {
                showTip(message: "用户名只能由数字和英文字母组成哦。")
                return
            } else if username.count > 12 {
                showTip(message: "用户名最长可以有 12 个字哦。")
                return
            }
            
            if username == "" { username = "anonymous" }
            self.delegate?.editFinished(username: username, content: content)
            UserDefaults.standard.set("", forKey: "feedbackContent")
            self.goBack()
        }
    }
}

extension String {
    func hasSpecialCharacters() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: .caseInsensitive)
            if regex.firstMatch(
                in: self,
                options: .reportCompletion, range: NSMakeRange(0, self.count)
            ) != nil {
                return true
            }
        } catch {
            debugPrint(error.localizedDescription)
            return false
        }
        
        return false
    }
}
