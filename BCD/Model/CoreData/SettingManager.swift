//
//  SettingManager.swift
//  BCD
//
//  Created by Liuliet.Lee on 27/6/2018.
//  Copyright © 2018 Liuliet.Lee. All rights reserved.
//

import Foundation
import CoreData

class SettingManager: CoreDataModel {
    
    private func initSetting() {
        let initHistoryNum: Int16 = 120
        let entity = NSEntityDescription.entity(forEntityName: "Setting", in: context)!
        let newItem = Setting(entity: entity, insertInto: context)
        newItem.historyNumber = initHistoryNum
        saveContext()
    }
    
    private var setting: Setting? {
        do {
            let searchResults = try context.fetch(Setting.fetchRequest())
            if searchResults.count == 0 {
                initSetting()
                return self.setting
            } else {
                return searchResults[0] as? Setting
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    var historyItemLimit: Int! {
        get {
            return Int(setting?.historyNumber ?? 0)
        }
        set {
            setting?.historyNumber = Int16(newValue)
            saveContext()
        }
    }
    
    var isSaveOriginImageData: Bool! {
        get {
            return Bool(setting?.saveOrigin ?? true)
        } set {
            setting?.saveOrigin = newValue
            saveContext()
        }
    }

}
