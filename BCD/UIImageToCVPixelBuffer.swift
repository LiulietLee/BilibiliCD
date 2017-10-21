//
//  File.swift
//  BasicCoreML
//
//  Created by Brian Advent on 09.06.17.
//  Copyright © 2017 Brian Advent. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resizeTo(newSize: CGSize) -> [UIImage?] {
        guard self.size != newSize else { return [self] }
        
        let w = self.size.width; let h = self.size.height
        
        let rects = [
            CGRect(x: 0, y: 0, width: h, height: h),
            CGRect(x: w - h, y: 0, width: h, height: h),
            CGRect(x: 0.5 * (w - h), y: 0, width: h, height: h)
        ]
        
        var results = [UIImage?]()
        
        for rect in rects {
            let rect = rect
            if let imageRef = self.cgImage!.cropping(to: rect) {
                let image: UIImage = UIImage(cgImage: imageRef)
                UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
                
                defer { UIGraphicsEndImageContext() }
                results.append(UIGraphicsGetImageFromCurrentImageContext())
            }
        }
        
        return results
    }
    
    func pixelBuffer() -> CVPixelBuffer? {
        
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: CGFloat(height))
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
