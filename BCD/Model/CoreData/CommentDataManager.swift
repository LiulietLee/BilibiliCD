//
//  CommentDataManager.swift
//  BCD
//
//  Created by Liuliet.Lee on 3/8/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation
import CoreData

class CommentDataManager: CoreDataModel {
    
    static func getCurrentData() -> [Comment] {
        var items: [Comment] = []
        
        do {
            let data = try context.fetch(CommentData.fetchRequest()) as! [CommentData]
            items = data.map({ (item) -> Comment in
                return Comment(
                    id: Int(item.id),
                    username: item.username!,
                    content: item.content!,
                    suki: Int(item.suki),
                    kirai: Int(item.kirai),
                    time: item.time!,
                    top: Int(item.top),
                    replyCount: Int(item.replyCount)
                )
            })
        } catch {
            print(error)
        }
        
        return items
    }
    
    static func clearData() {
        do {
            let items = try context.fetch(CommentData.fetchRequest()) as! [CommentData]
            items.forEach {
                context.delete($0)
                saveContext()
            }
        } catch {
            print(error)
        }
    }
    
    static func refreshData(_ data: [Comment]) {
        clearData()
        data.forEach {
            let entity = NSEntityDescription.entity(forEntityName: "CommentData", in: context)!
            let newItem = CommentData(entity: entity, insertInto: context)
            
            newItem.id = Int16($0.id)
            newItem.username = $0.username
            newItem.content = $0.content
            newItem.kirai = Int16($0.kirai)
            newItem.suki = Int16($0.suki)
            newItem.time = $0.time
            newItem.top = Int16($0.top)
            newItem.replyCount = Int16($0.replyCount)
            
            saveContext()
        }
    }
}

