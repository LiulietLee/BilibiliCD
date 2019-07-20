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
        if let username = usernameField.text,
            let content = textView.text,
            username != "",
            content != "" {
            postButton.isEnabled = false
            
            let completion: (Int?) -> Void = { [weak self] (status) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch status {
                    case 200:
                        self.delegate?.editFinished(username: username, content: content)
                        self.goBack()
                    default:
                        print("error status code: \(status ?? -1)")
                        self.postButton.isEnabled = true
                    }
                }
            }
            
            switch model {
            case .comment:
                commentProvider.newComment(username: username, content: content, completion: completion)
            case .reply:
                if let comment = currentComment {
                    commentProvider.newReply(commentID: comment.id, username: username, content: content, completion: completion)
                } else {
                    delegate?.editFinished(username: username, content: content)
                    goBack()
                }
            }
        } else {
            // TODO: - dialog
        }
    }
}
