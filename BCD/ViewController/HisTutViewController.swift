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

        webView = WKWebView()
        if #available(iOS 13.0, *) {
            webView.isOpaque = false
            webView.backgroundColor = .systemBackground
        }

        let url = Bundle.main.url(forResource: "HisTutPage/\(page)", withExtension: "html")
        let request = URLRequest(url: url!)
        webView.load(request)

        let margin: CGFloat = 20.0
        let width: CGFloat = 40.0
        back = UIButton()
        back.setImage(#imageLiteral(resourceName: "ic_arrow_downward"), for: .normal)
        back.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        if #available(iOS 13.4, *) {
            // TODO: - 这是个啥
//            back.isPointerInteractionEnabled = true
        }

        view.addSubview(webView)
        view.addSubview(back)
        webView.translatesAutoresizingMaskIntoConstraints = false
        back.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            back.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: margin),
            back.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            back.widthAnchor.constraint(equalToConstant: width),
            back.heightAnchor.constraint(equalToConstant: width),
        ])
    }
    
    @objc private func goBack() {
        dismiss(animated: true)
    }
}
