//
//  SettingViewController.swift
//  BCD
//
//  Created by Liuliet.Lee on 17/12/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import Eureka
import LLDialog

protocol HistoryLimitDelegate {
    func historyChanged()
}

class SettingViewController: FormViewController {
    
    private var settingManager = SettingManager()
    var delegate: HistoryLimitDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form
            +++ Section("历史记录设定")
            <<< SwitchRow() { row in
                row.title = "在保存记录时保存封面原图"
                row.value = settingManager.isSaveOriginImageData
                row.onChange { row in
                    self.settingManager.isSaveOriginImageData = row.value
                }
            }
            <<< ButtonRow() { row in
                row.title = "清除封面原图（不清除记录）"
                row.onCellSelection { (_, _) in
                    LLDialog()
                        .set(title: "清除封面原图")
                        .set(message: "这个动作会清除 Bili Cita 本地保存的所有封面原图，但不会清除历史记录本身，这样可以节省本地存储空间。\n\n在下次访问某条记录的时候 Bili Cita 会从 B 站服务器下载原封面，而这可能会引起流量计费。")
                        .setNegativeButton(withTitle: "不要")
                        .setPositiveButton(withTitle: "好的", target: self, action: #selector(self.removeAllOriginCover))
                        .show()
                }
            }
            <<< ButtonRow() { row in
                row.title = "清空历史记录"
                row.onCellSelection { (_, _) in
                    LLDialog()
                        .set(title: "清空历史记录")
                        .set(message: "要清空历史记录吗？")
                        .setNegativeButton(withTitle: "不要")
                        .setPositiveButton(withTitle: "好的", target: self, action: #selector(self.clearHistory))
                        .show()
                }.cellSetup { (cell, button) in
                    cell.tintColor = .red
                }
            }
            
            +++ Section()
            <<< PhoneRow() { row in
                row.title = "历史记录数量限制"
                row.placeholder = "设定历史记录保存的最大数量"
                row.value = String(settingManager.historyItemLimit)
                row.tag = "num-limit"
            }
            <<< ButtonRow() { row in
                row.title = "确定"
                row.onCellSelection { (_, _) in
                    self.dismiss(animated: true) { [weak self] in
                        if let self = self,
                            let row = self.form.rowBy(tag: "num-limit") as? PhoneRow {
                            self.settingManager.historyItemLimit = Int(row.value ?? "0")
                            self.delegate?.historyChanged()
                        }
                    }
                }
            }
    }
    
    @objc private func removeAllOriginCover() {
        let manager = HistoryManager()
        manager.removeAllOriginCover()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func clearHistory() {
        let manager = HistoryManager()
        manager.clearHistory()

        dismiss(animated: true) { [weak self] in
            if let self = self {
                self.delegate?.historyChanged()
            }
        }
    }
}
