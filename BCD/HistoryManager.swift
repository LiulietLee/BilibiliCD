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
    
    func refreshHistory() {
        if let limit = SettingManager.historyItemLimit {
            checkHistoryNumLimit(limit)
        }
    }
    
    func fetchHistory() -> [History] {
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
    
    @discardableResult
    func addNewHistory(av: String, image: Image, title: String, up: String, url: String, date: Date = Date()) -> History {
        refreshHistory()
        
        let entity = NSEntityDescription.entity(forEntityName: "History", in: context)!
        let newItem = History(entity: entity, insertInto: context)
        
        let list = fetchHistory()
        if list.count != 0, list[0].up == up && list[0].av == av { return list[0] }
        
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
        
        let origEntity = NSEntityDescription.entity(forEntityName: "OriginCover", in: context)!
        let newOrig = OriginCover(entity: origEntity, insertInto: context)
        newOrig.image = originCoverData
        
        newItem.origin = newOrig
        newOrig.history = newItem
        
        CoreDataModel.saveContext()
        
        return newItem
    }
    
    func isNeedHid(_ cover: UIImage) -> Bool {
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
    
    func isExistInHistory(cover: BilibiliCover? = nil, stringID: String? = nil) -> History? {
        if cover == nil && stringID == nil { return nil }
        let history = fetchHistory()
        
        for item in history {
            if cover != nil, item.av == cover!.shortDescription {
                return item
            }
            if stringID != nil, item.av == stringID {
                return item
            }
        }
        
        return nil
    }
    
    func changeOriginCover(of item: History, image: UIImage) {
        item.origin?.image = image.data()
        CoreDataModel.saveContext()
    }
    
    func changeIsHiddenOf(_ item: History) {
        item.isHidden = !item.isHidden
        CoreDataModel.saveContext()
    }
    
    func deleteHistory(_ item: History) {
        context.delete(item)
        CoreDataModel.saveContext()
    }
    
    func clearHistory() {
        do {
            let items = try context.fetch(History.fetchRequest()) as! [History]
            for item in items { deleteHistory(item) }
        } catch {
            print(error)
        }
    }
    
    private func checkHistoryNumLimit(_ limit: Int, history: [History]! = nil) {
        var list = history ?? fetchHistory()
        let count = list.count
        if count == 0 { return }
        let overflow = count - limit
        if overflow > 0 {
            for i in 0..<overflow {
                deleteHistory(list[count - 1 - i])
            }
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
