//
//  FindArtViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 19/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class FindArtViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.text = "    まあ〜说是美工，其实只要会画画就行了。因为以我这个三流编程水平，太高端的界面也做不粗来，现在这个界面已经是我这个理工男的能力极限了。不用你说我也知道它很挫，但我有什么办法，我也很绝望啊( ´_ゝ｀)\n\n    因此我希望能找个会画画的（妹子）帮忙画几幅插画放到这个App里面，让App变得更萌一点。如果你有时间，有能力的话，欢迎加入我们！"
        textView.sizeToFit()
    }
    
    @IBAction func joinButtonTapped() {
        let url = "https://space.bilibili.com/4056345/#!/"
        UIApplication.shared.open(URL(string: url)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
