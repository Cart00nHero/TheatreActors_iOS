//
//  ToolMan.swift
//  WhatToEat
//
//  Created by YuCheng on 2021/3/3.
//  Copyright © 2021 YuCheng. All rights reserved.
//

import Foundation
import Theatre
import SwiftUI

class ToolMan: Actor {
    private func actResizeImage(
        _ image: UIImage,
        _ newSize: CGSize,
        export: Teleport<UIImage>
    ) {
        Task {
            export.portal = resizeImage(image: image, targetSize: newSize)
        }
    }
    private func actBase64Image(_ image: UIImage, export: Teleport<String?>) {
        /*
         //jpeg格式 compressionQuality: 壓縮質量
         guard let imageData = image.jpegData(compressionQuality: 1) else {
         return
         }*/
        //png格式
        Task {
            guard let imageData = image.pngData() else {
                export.portal = nil
                return
            }
            let base64ImageStr: String = imageData.base64EncodedString(
                options: .lineLength64Characters)
            export.portal = base64ImageStr
        }
    }
    private func actBase64ToImage(_ base64Text: String, export: Teleport<UIImage?>) {
        Task {
            if let dataDecoded: Data = Data(
                base64Encoded: base64Text,
                options: .ignoreUnknownCharacters),
               let decodedImage = UIImage(data: dataDecoded) {
                export.portal = decodedImage
            } else {
                export.portal = nil
            }
        }
    }
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(
                width: size.width * heightRatio,
                height: size.height * heightRatio)
        } else {
            newSize = CGSize(
                width: size.width * widthRatio,
                height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(
            x: 0, y: 0, width: newSize.width,
            height: newSize.height)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
extension ToolMan {
    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage {
        let export = install(UIImage())
        act { [unowned self] in
            actResizeImage(image, newSize, export: export)
        }
        return export.portal
    }
    func base64Image(image: UIImage) -> String? {
        let export = install(String?(nil))
        act { [unowned self] in
            actBase64Image(image, export: export)
        }
        return export.portal
    }
    func base64ToImage(base64Text: String) -> UIImage? {
        let export = install(UIImage?(nil))
        act { [unowned self] in
            actBase64ToImage(base64Text, export: export)
        }
        return export.portal
    }
}
