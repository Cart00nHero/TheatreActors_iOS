//
//  LinkResourcePrivider.swift
//  eMenu
//
//  Created by YuCheng on 2024/6/27.
//

import Foundation
import Theatre
import SwiftUI
import LinkPresentation
import AVFoundation

class WebMediaProvider: Actor {
    private func actFetchUrlImage(_ url: URL, export: Teleport<UIImage?>) {
        // Create a data task to fetch the image data
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Ensure there is no error and data is non-nil
            guard let data = data, error == nil else {
                print("Error fetching image: \(error?.localizedDescription ?? "Unknown error")")
                export.portal = nil
                return
            }
            // Create a UIImage from the fetched data
            let image = UIImage(data: data)
            // Execute the completion handler on the main thread
            export.portal = image
        }
        // Start the data task
        task.resume()
    }
    private func actFetchMetadata(_ url: URL, export: Teleport<LPLinkMetadata?>) {
        let metadataProvider = LPMetadataProvider()
        metadataProvider.startFetchingMetadata(for: url) { metadata, error in
            if let error = error {
                print("Error fetching metadata: \(error.localizedDescription)")
                export.portal = nil
            } else {
                export.portal = metadata
            }
        }
    }
    private func actFetchMetaImage(_ url: URL, export: Teleport<UIImage?>) {
        let metadataProvider = LPMetadataProvider()
        metadataProvider.startFetchingMetadata(for: url) { metadata, error in
            guard let metadata = metadata, error == nil else {
                export.portal = nil
                return
            }
            
            if let imageProvider = metadata.imageProvider {
                imageProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        export.portal = image
                    } else {
                        export.portal = nil
                    }
                }
            } else {
                export.portal = nil
            }
        }
    }
    private func actGenerateThumbnail(_ videoUrl: URL, export: Teleport<UIImage?>) {
        let asset = AVAsset(url: videoUrl)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        // Set the time to get the thumbnail (e.g., at the 2-second mark)
        let time = CMTime(seconds: 2.0, preferredTimescale: 600)
        let times = [NSValue(time: time)]
        
        assetImgGenerate.generateCGImagesAsynchronously(forTimes: times) { _, image, _, _, error in
            if let cgImage = image {
                let thumbnail = UIImage(cgImage: cgImage)
                export.portal = thumbnail
            } else {
                print("Error generating thumbnail: \(error?.localizedDescription ?? "unknown error")")
                export.portal = nil
            }
        }
    }
    private func actGetLegitimateUrl(_ linkUrl: String) -> URL? {
        guard let theUrl = URL(string: linkUrl) else {
            return nil
        }
        let reachable = checkImageURLLegitimacy(theUrl)
        if reachable {
            return theUrl
        } else {
            return nil
        }
    }
    
    // MARK: - Private
    private func checkImageURLLegitimacy(_ url: URL) -> Bool {
        let export = install(false)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                export.portal = (httpResponse.statusCode == 200 && data != nil)
            } else {
                export.portal = false
            }
        }
        task.resume()
        return export.portal
    }
}
extension WebMediaProvider: WebMediaProviderBehaviors {
    func getLegitimateUrl(from linkUrl: String) -> Teleport<URL?> {
        let export = install(URL?(nil))
        act { [unowned self] in
            export.portal = actGetLegitimateUrl(linkUrl)
        }
        return export
    }
    
    func fetchUrlImage(from url: URL) -> Teleport<UIImage?> {
        let export = install(UIImage?(nil))
        act { [unowned self] in
            actFetchUrlImage(url, export: export)
        }
        return export
    }
    func fetchMetadata(from url: URL) -> Teleport<LPLinkMetadata?> {
        let export = install(LPLinkMetadata?(nil))
        act { [unowned self] in
            actFetchMetadata(url, export: export)
        }
        return export
    }
    func fetchMetaImage(from url: URL) -> Teleport<UIImage?> {
        let export = install(UIImage?(nil))
        act { [unowned self] in
            actFetchMetaImage(url, export: export)
        }
        return export
    }
    func generateThumbnail(from videoUrl: URL) -> Teleport<UIImage?> {
        let export = install(UIImage?(nil))
        act { [unowned self] in
            actGenerateThumbnail(videoUrl, export: export)
        }
        return export
    }
}

protocol WebMediaProviderBehaviors {
    func getLegitimateUrl(from linkUrl: String) -> Teleport<URL?>
    func fetchUrlImage(from url: URL) -> Teleport<UIImage?>
    func fetchMetadata(from url: URL) -> Teleport<LPLinkMetadata?>
    func fetchMetaImage(from url: URL) -> Teleport<UIImage?>
    func generateThumbnail(from videoUrl: URL) -> Teleport<UIImage?>
}
