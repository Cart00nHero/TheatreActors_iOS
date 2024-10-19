//
//  QRCoder.swift
//  eMenu
//
//  Created by YuCheng on 2024/4/10.
//

import Foundation
import Theatre
import UIKit
import CoreImage.CIFilterBuiltins
import Photos

class QRCoder: Actor {
    private func actGenerateQRCode(message: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(message.utf8)
        guard let outputImg: CIImage = filter.outputImage else {
            return nil
        }
        return convertCIImageToUIImage(ciImage: outputImg)
    }
    private func actDecodeQRCode(_ image: UIImage) -> [String] {
        var messages: [String] = []
        guard let features: [CIFeature] = detectQRCode(image) else {
            return []
        }
        for case let row as CIQRCodeFeature in features{
            let qrcodeMsg = row.messageString ?? ""
            if !qrcodeMsg.isEmpty {
                messages.append(qrcodeMsg)
            }
        }
        return messages
    }
    private func actBuildSMSMessage(_ sms: String) -> (Bool, String) {
        let tempMsg: String = sms
        guard tempMsg.lowercased().hasPrefix("smsto") else {
            return (false, "")
        }
        let splitArray = sms.split(separator: ":")
        guard splitArray.count >= 3 else {
            return (false, "")
        }
        let sliceArr = splitArray[2 ..< splitArray.count]
        let bodyText = NSMutableString()
        for text in sliceArr {
            bodyText.append(String(text))
        }
        let sendSMSText = "sms:\(splitArray[1])&body=\(bodyText)"
        return (true, sendSMSText)
    }
    private func actAskPhotoAuthorization() -> PHAuthorizationStatus {
        let export = install(PHAuthorizationStatus.notDetermined)
        PHPhotoLibrary.requestAuthorization { status in
            export.portal = status
        }
        return export.portal
    }
    
    //MARK: - Private
    private func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        if let image = image, let ciImage = CIImage.init(image: image){
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            } else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            return features
        }
        return nil
    }

    private func convertCIImageToUIImage(ciImage: CIImage) -> UIImage {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return UIImage()
    }
    
    private func saveImageToPhotoLibrary(_ image: UIImage) {
        // 檢查對照片庫訪問授權狀態
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // 確保在主線程上執行此操作
                DispatchQueue.main.async {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            } else {
                // 處理未授權訪問，或許提醒用戶
                print("沒有獲得照片庫的訪問權限。")
            }
        }
    }

}
extension QRCoder {
    func generateQRCode(from message: String) -> Teleport<UIImage?> {
        let export = install(UIImage?(nil))
        act { [unowned self] in
            export.portal = actGenerateQRCode(message: message)
        }
        return export
    }
    func decodeQRCode(image: UIImage) -> Teleport<[String]> {
        let export = install([String]())
        act { [unowned self] in
            export.portal = actDecodeQRCode(image)
        }
        return export
    }
    func askPhotoAuthorization() -> Teleport<PHAuthorizationStatus> {
        let export = install(PHAuthorizationStatus.notDetermined)
        act { [unowned self] in
            export.portal = actAskPhotoAuthorization()
        }
        return export
    }
}
