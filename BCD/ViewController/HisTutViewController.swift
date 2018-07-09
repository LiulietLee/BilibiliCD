//
//  HisTutViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 12/10/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import WebKit

class HisTutViewController: UIViewController {

    private var webView: WKWebView!
    private var back: UIButton!
    
    var page = "index"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let size = view.bounds
        webView = WKWebView()
        webView.frame = CGRect(x: 0.0, y: -20.0, width: size.width, height: size.height + 22.0)
        
        let url = Bundle.main.url(forResource: "HisTutPage/\(page)", withExtension: "html")
        let request = URLRequest(url: url!)
        webView.load(request)
        
        let margin: CGFloat = 20.0
        let width: CGFloat = 40.0
        back = UIButton()
        back.frame = CGRect(x: size.width - margin - width,
                            y: margin * 1.25, width: width, height: width)
        
        if UIDevice().isiPhoneX {
            // 我真特么想一锤子锤烂 iPhone X ！这哪个ZZ设计出来的这么奇葩的屏幕啊 ！
            webView.frame = CGRect(x: 0.0, y: -45.0, width: size.width, height: size.height + 40.0)
            back = UIButton(frame: CGRect(x: size.width - margin - width,
                                          y: margin * 1.75, width: width, height: width))
        }
        
        back.setImage(#imageLiteral(resourceName: "ic_arrow_downward"), for: .normal)
        back.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        view.addSubview(webView)
        view.addSubview(back)
    }
    
    @objc private func goBack() {
        dismiss(animated: true, completion: nil)
    }
}
