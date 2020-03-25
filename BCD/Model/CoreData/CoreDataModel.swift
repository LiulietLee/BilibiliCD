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
import ImageIO

class CoreDataModel {
    let context = CoreDataStorage.sharedInstance.mainQueueContext
   
    static let context = CoreDataStorage.sharedInstance.mainQueueContext

    func saveContext() {
        CoreDataStorage.sharedInstance.saveContext(context)
    }
    
    static func saveContext() {
        CoreDataStorage.sharedInstance.saveContext(context)
    }
}

extension CGSize {
    static let coverThumnailSize = CGSize(
        width: 125 * UIScreen.main.scale,
        height: 78 * UIScreen.main.scale
    )
}

extension UIImage {
    func data() -> Data {
        return pngData()!
    }
    
    func resized(to size: CGSize = .coverThumnailSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        return resizedImage
    }
}

extension Data {
    func toImage(sized size: CGSize = .coverThumnailSize) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: Swift.max(size.width, size.height)
        ]

        guard let imageSource = CGImageSourceCreateWithData(self as CFData, nil),
            let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
        else {
            return nil
        }

        return UIImage(cgImage: image)
    }
}

extension String {
    var isGIF: Bool {
        return hasSuffix("gif")
    }
}
