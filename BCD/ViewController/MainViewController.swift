//
//  MainViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/6/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import SWRevealViewController
import ViewAnimator

class MainViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var avLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var menu: UIBarButtonItem!
    private var touchTime = DispatchTime(uptimeNanoseconds: 0)
    private var manager = HistoryManager()
//    private var existCover: History? = nil
    var cover = BilibiliCover(number: 0, type: .video) {
        didSet {
            avLabel?.text = cover.shortDescription
            if cover.number == 0 {
                goButton.isEnabled = false
            } else {
                goButton.isEnabled = true
            }
        }
    }
    private var avNumber: UInt64 {
        get { return cover.number }
        set { cover.number = newValue }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = .bilibiliPink
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getURLFromPasteboard),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getURLFromPasteboard()
    }

    @objc private func getURLFromPasteboard() {
        if isShowingImage { return }
        
        if let newCover = BilibiliCover.fromPasteboard() {
            if cover != newCover {
                cover = newCover
            } else {
                return
            }
            if manager.isExistInHistory(cover: newCover) == nil {
                isShowingImage = true
                let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "image controller") as! ImageViewController
                
                nextViewController.cover = newCover
                show(nextViewController, sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isShowingImage = false
        goButton.isEnabled = false
        menu.target = revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if needToDisplayAppTutorial {
            showAppTutorialMessage()
        }
        
        if needToDisplayAutoHidTutorial {
            showAutoHidTutorialMessage()
        }
        
        setSwitchCoverTypeButton()
    }
    
    private func setSwitchCoverTypeButton() {
        let button = UIButton()
        button.addTarget(self, action: #selector(switchCoverType), for: .touchUpInside)
        view.addSubview(button)
        view.bringSubviewToFront(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: avLabel.topAnchor),
            button.leadingAnchor.constraint(equalTo: avLabel.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: avLabel.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: avLabel.bottomAnchor)
        ])
    }
    
    @objc private func switchCoverType() {
        let currentType = cover.type.rawValue
        let nextType = currentType % 3 + 1
        cover = BilibiliCover(number: cover.number, type: CoverType(rawValue: nextType)!)
    }
    
    private func showAutoHidTutorialMessage() {
        let dialog = LLDialog()
        dialog.title = "(=・ω・=)"
        dialog.message = "想了解下「自动和谐」的什么东西嘛？"
        dialog.setNegativeButton(withTitle: "不想")
        dialog.setPositiveButton(withTitle: "好的", target: self, action: #selector(showAutoHidTutorial))
        dialog.show()
    }
    
    private func showAppTutorialMessage() {
        let dialog = LLDialog()
        dialog.title = "(=・ω・=)"
        dialog.message = "想看看这个 App 的使用说明嘛？"
        dialog.setNegativeButton(withTitle: "不想")
        dialog.setPositiveButton(withTitle: "好的", target: self, action: #selector(showAppTutorial))
        dialog.show()
    }
    
    @objc private func showAutoHidTutorial() {
        let vc = HisTutViewController()
        vc.page = "AutoHide"
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func showAppTutorial() {
        let tutorialViewController = storyboard?.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        present(tutorialViewController, animated: true, completion: nil)
    }
    
    @IBAction func numberButtonTapped(_ sender: UIButton) {
        let new = sender.currentTitle!
        avNumber = avNumber &* 10 &+ UInt64(new)!
    }
    
    @IBAction func touchBackButtonDown() {
        touchTime = DispatchTime.now()
    }
    @IBAction func touchBackButtonUp() {
        let endTime = DispatchTime.now()
        let nanoTime = endTime.uptimeNanoseconds - touchTime.uptimeNanoseconds
        let interval = Double(nanoTime) / 1_000_000_000
        
        if (interval > 0.4) {
            avNumber = 0
        } else {
            avNumber /= 10
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ImageViewController {
            vc.cover = cover
            if let eCover = manager.isExistInHistory(cover: cover) {
                vc.itemFromHistory = eCover
            }
        }
    }
    
}
