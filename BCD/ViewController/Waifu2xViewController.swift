//
//  Waifu2xViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 27/10/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import LLDialog

protocol Waifu2xDelegate {
    func scaleSucceed(scaledImage: UIImage)
}

class Waifu2xViewController: UIViewController, ScalingViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    var originImage: UIImage?
    var delegate: Waifu2xDelegate?
    
    private var protoc = [0, 2, 1] // protoc = [次元, 降噪, 放大]
    private let header = ["次元", "降噪", "放大"]
    private let footer = ["次元壁不可破！", "这是选降噪力度的，建议用强度大一点的", ""]
    private let list = [
        ["二次元", "三次元"],
        ["None", "Low", "Medium", "High", "Lunatic"],
        ["None", "2x"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        tableView.tintColor = navigationController?.navigationBar.barTintColor
        startButton.backgroundColor = navigationController?.navigationBar.barTintColor
        
        if originImage != nil,
            originImage!.size.width <= 150 || originImage!.size.height <= 150 {
            startButton.setTitle("图片太小啦", for: .normal)
            startButton.isEnabled = false
        }
        
        print("image width: \(originImage!.size.width), height: \(originImage!.size.height)")
    }
    
    @objc func goBack() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openTut() {
        let vc = HisTutViewController()
        vc.page = "AboutWaifu2x"
        present(vc, animated: true)
    }
    
    @IBAction func startScale() {
        startButton.isEnabled = false
    }
    
    func scaleSucceed(scaledImage: UIImage) {
        delegate?.scaleSucceed(scaledImage: scaledImage)
        navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            protoc[indexPath.section] = indexPath.row
            for i in 0..<list[indexPath.section].count {
                let currentIndex = IndexPath(row: i, section: indexPath.section)
                if currentIndex != indexPath,
                    let deselectCell = tableView.cellForRow(at: currentIndex) {
                    deselectCell.accessoryType = .none
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let text = list[indexPath.section][indexPath.row]
        cell.textLabel?.text = text
        if protoc[indexPath.section] == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return header[section]
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return footer[section]
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ScalingViewController {
            vc.image = originImage!
            vc.delegate = self
            vc.protoc = protoc
        }
    }
}
