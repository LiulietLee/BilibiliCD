//
//  ImageSaver.swift
//  BCD
//
//  Created by Apollo Zhu on 3/8/18.
//  Copyright © 2018 Liuliet.Lee. All rights reserved.
//

import UIKit
import Photos

enum Image {
    case gif(UIImage, data: Data)
    case normal(UIImage)
    var uiImage: UIImage {
        switch self {
        case let .normal(img): return img
        case .gif(let img, data: _): return img
        }
    }
}

class ImageSaver {
    static func saveImage(_ image: Image,
                          completionHandler: ((Bool, Error?) -> Void)? = nil,
                          alternateHandler: Selector? = nil) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            saveImage(image, hasPermission: true,
                      completionHandler: completionHandler,
                      alternateHandler: alternateHandler)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                if status == .notDetermined {
                    completionHandler?(false, nil)
                } else {
                    saveImage(image,
                              completionHandler: completionHandler,
                              alternateHandler: alternateHandler)
                }
            }
        case .restricted, .denied:
            saveImage(image, hasPermission: false,
                      completionHandler: completionHandler,
                      alternateHandler: alternateHandler)
        }
    }
    
    static func saveImage(_ image: Image, hasPermission: Bool,
                          completionHandler: ((Bool, Error?) -> Void)? = nil,
                          alternateHandler: Selector? = nil) {
        if hasPermission {
            let data: Data
            switch image {
            case .gif(_, data: let gifData):
                data = gifData
            case .normal(let uiImage):
                data = uiImage.data()
            }
            PHPhotoLibrary.shared()
                .performChanges({
                    PHAssetCreationRequest.forAsset()
                        .addResource(with: .photo, data: data, options: nil)
                }, completionHandler: completionHandler
            )
        } else {
            UIImageWriteToSavedPhotosAlbum(image.uiImage, self, alternateHandler, nil)
        }
    }
}
