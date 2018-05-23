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
    private var dataModel = CoreDataModel()
    private var existCover: History? = nil
    var cover = BilibiliCover(number: 0, type: .video) {
        didSet {
            avLabel?.text = cover.shortDescription
            if cover.number == 0 {
                goButton.isEnabled = false
                if cover.type != .video {
                    cover = BilibiliCover(number: 0, type: .video)
                }
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
                                               name: .UIApplicationDidBecomeActive,
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
            self.cover = newCover
            if let temp = dataModel.isExistInHistory(cover: newCover) {
                existCover = temp
            } else {
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
        
        if isNeedToDisplayAutoHis {
            showTutMessage()
        }
    }
    
    private func showTutMessage() {
        let dialog = LLDialog()
        dialog.title = "(=・ω・=)"
        dialog.message = "想了解下「自动和谐」的什么东西嘛？"
        dialog.setNegativeButton(withTitle: "不想")
        dialog.setPositiveButton(withTitle: "好的", target: self, action: #selector(showTutorial))
        dialog.show()
    }
    
    @objc private func showTutorial() {
        let vc = HisTutViewController()
        vc.page = "AutoHide"
        present(vc, animated: true, completion: nil)
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
            if let eCover = existCover,
                eCover.av == cover.shortDescription {
                vc.itemFromHistory = existCover
            }
        }
    }
    
}
