//
//  CoreDataModel.swift
//  BCD
//
//  Created by Liuliet.Lee on 13/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class CoreDataModel {
    
    internal let context = CoreDataStorage.sharedInstance.mainQueueContext
    
    internal func saveContext() {
        CoreDataStorage.sharedInstance.saveContext(context)
    }
}

extension UIImage {
    func data() -> Data {
        return self.pngData()!
    }
    
    func resized(to size: CGSize = CGSize(width: 135, height: 84)) -> UIImage {
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        return resizedImage
    }
}

extension String {
    var isGIF: Bool {
        return hasSuffix("gif")
    }
}
