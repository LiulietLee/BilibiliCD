//
//  HistoryManager.swift
//  BCD
//
//  Created by Liuliet.Lee on 27/6/2018.
//  Copyright © 2018 Liuliet.Lee. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class HistoryManager: CoreDataModel {

    private var historyLimit: Int {
        let settingManager = SettingManager()
        return settingManager.historyItemLimit
    }

    func getHistory() -> [History] {
        var history = fetchHistory()
        let count = history.count
        let overflow = count - historyLimit
        if overflow > 0 {
            for i in 0..<overflow {
                deleteHistory(history[count - 1 - i])
            }
            history = Array(history.dropLast(overflow))
        }
        return history
    }
    
    private func fetchHistory() -> [History] {
        var items = [History]()
        
        let sort = NSSortDescriptor(key: #keyPath(History.date), ascending: false)
        let request = NSFetchRequest<History>(entityName: "History")
        request.sortDescriptors = [sort]
        
        do {
            items = try context.fetch(request)
        } catch {
            print(error)
        }
        
        return items
    }

    @available(*, deprecated)
    private func avOfLatestHistoryEqualTo(_ av: String) -> Bool {
        let history = fetchHistory()
        return history.count == 0 ? false : (av == history[0].av)
    }
    
    @discardableResult
    func addNewHistory(av: String, image: Image, title: String, up: String, url: String, date: Date = Date()) -> History {
        var newItem: History
        
        if let existedItem = itemInHistory(stringID: av) {
            newItem = existedItem
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "History", in: context)!
            newItem = History(entity: entity, insertInto: context)
        }
        
        let uiImage = image.uiImage
        let originCoverData: Data
        switch image {
        case .gif(_, data: let data):
            originCoverData = data
        case .normal:
            originCoverData = uiImage.data()
        }
        let resizedCoverData = uiImage.resized().data()
        
        newItem.av = av
        newItem.date = date
        newItem.image = resizedCoverData
        newItem.title = title
        newItem.up = up
        newItem.url = url
        newItem.isHidden = isNeedHid(uiImage)
        
        if needToSetSaveOriginTrue {
            SettingManager().isSaveOriginImageData = true
        }
        
        if (SettingManager().isSaveOriginImageData) {
            let origEntity = NSEntityDescription.entity(forEntityName: "OriginCover", in: context)!
            let newOrig = OriginCover(entity: origEntity, insertInto: context)
            newOrig.image = originCoverData
            
            newItem.origin = newOrig
            newOrig.history = newItem
        }
        
        saveContext()
        
        return newItem
    }
    
    private func isNeedHid(_ cover: UIImage) -> Bool {
        let size = CGSize(width: 224, height: 224)
        
        let resizedImages = cover.resizeTo(newSize: size)
        
        for image in resizedImages {
            guard let buffer = image?.pixelBuffer() else {
                fatalError("Converting to pixel buffer failed!")
            }
            
            guard let result = try? Nudity().prediction(data: buffer) else {
                fatalError("Prediction failed!")
            }
            
            let confidence = result.prob["SFW"]! * 100.0
            let converted = String(format: "%.2f", confidence)
            
            print("SFW - \(converted) %")
            
            if confidence < 70.0 { return true }
        }
        
        return false
    }
    
    func itemInHistory(cover: BilibiliCover? = nil, stringID: String? = nil) -> History? {
        let request = NSFetchRequest<History>(entityName: "History")
        if cover != nil {
            request.predicate = NSPredicate(format: "av = %@", cover!.shortDescription)
        } else if stringID != nil {
            request.predicate = NSPredicate(format: "av = %@", stringID!)
        } else {
            return nil
        }
        
        var items = [History]()
        do {
            items = try context.fetch(request)
        } catch {
            print(error)
        }
        
        return items.count == 0 ? nil : items[0]
    }
    
    func replaceOriginCover(of item: History, with image: UIImage) {
        item.origin?.image = image.data()
        saveContext()
    }
    
    func toggleIsHidden(of item: History) {
        item.isHidden.toggle()
        saveContext()
    }
    
    func deleteHistory(_ item: History) {
        if let origin = item.origin {
            context.delete(origin)
        }
        context.delete(item)
        saveContext()
    }
    
    func clearHistory() {
        do {
            let items = try context.fetch(History.fetchRequest()) as! [History]
            items.forEach(deleteHistory)
        } catch {
            print(error)
        }
    }

    func removeAllOriginCover() {
        do {
            let items = try context.fetch(History.fetchRequest()) as! [History]
            items.forEach { (history) in
                if let origin = history.origin {
                    context.delete(origin)
                    history.origin = nil
                    saveContext()
                }
            }
        } catch {
            print(error)
        }
    }
    
    func importFromCache() {
        let cacheManager = CacheManager()
        let items = cacheManager.getCache()
        
        if (items.count == 0) { return }
        
        for item in items {
            addNewHistory(
                av: item.stringID!,
                image: item.isGIF ? .gif(item.uiImage!, data: item.image!) : .normal(item.uiImage!),
                title: item.title!,
                up: item.author!,
                url: item.imageURL!,
                date: item.date!
            )
            
            cacheManager.deleteDraft(item)
        }
    }
}

extension History {
    var isGIF: Bool! {
        return url?.isGIF
    }
    var uiImage: UIImage? {
        if let originCoverData = origin?.image {
            if isGIF {
                return UIImage.gif(data: originCoverData)
            } else {
                return UIImage(data: originCoverData)
            }
        } else if let data = image {
            return UIImage(data: data)
        } else { return nil }
    }
}
