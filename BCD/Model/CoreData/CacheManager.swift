//
//  CacheManager.swift
//  BCD
//
//  Created by Liuliet.Lee on 27/6/2018.
//  Copyright © 2018 Liuliet.Lee. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CacheManager: CoreDataModel {
    
    func addNewDraft(stringID: String, title: String, imageURL: URL, author: String, image: Image) {
        let entity = NSEntityDescription.entity(forEntityName: "Draft", in: context)
        let newItem = Draft(entity: entity!, insertInto: context)
        
        newItem.stringID = stringID
        newItem.title = title
        newItem.imageURL = imageURL.absoluteString
        newItem.author = author
        newItem.image = image.uiImage.data()
        newItem.date = Date()
        
        saveContext()
    }
    
    private func deleteDraft(_ draft: Draft) {
        context.delete(draft)
        saveContext()
    }
    
}

extension Draft {
    var isGIF: Bool! {
        return imageURL?.isGIF
    }
    var uiImage: UIImage? {
        if let CoverData = image {
            if isGIF {
                return UIImage.gif(data: CoverData)
            } else {
                return UIImage(data: CoverData)
            }
        } else if let data = image {
            return UIImage(data: data)
        } else { return nil }
    }
}
