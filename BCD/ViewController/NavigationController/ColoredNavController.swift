//
//  ColoredNavController.swift
//  BCD
//
//  Created by Liuliet.Lee on 11/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class ColoredNavController: UINavigationController {
    var navbarTintColor: UIColor { return .black }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barTintColor = navbarTintColor
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        navigationBar.barStyle = .black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        let alert = UIAlertController(title: "GDPR", message: "管理数据（试用）", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "导出", style: .default) { _ in
            CoreDataStorage.sharedInstance.saveCoreDataModelToDocuments()
        })
        alert.addAction(UIAlertAction(title: "导入", style: .destructive) { _ in
            CoreDataStorage.sharedInstance.replaceCoreDataModelWithOneInDocuments()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
}

extension UIColor {
    static let tianyiBlue = UIColor(hex: 0x56bcef)
    static let bilibiliPink = #colorLiteral(red: 1, green: 0.2319664663, blue: 0.4985880365, alpha: 1)
    static let mikuGreen = UIColor(hex: 0x137a7f)
    static let inariHair = UIColor(hex: 0xCB7F53)
}
