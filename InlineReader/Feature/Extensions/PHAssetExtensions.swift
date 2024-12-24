//
//  File.swift
//  
//
//  Created by Rodrigo Labrador Serrano on 5/9/23.
//

import Photos
import UIKit

extension PHAsset {
    var ext: String? {
        guard let path = self.value(forKey: "filename") as? String else { return nil }
        return URL(fileURLWithPath: path).pathExtension
    }

    public func tempCopyFile(videoRequestOptions: PHVideoRequestOptions? = nil,
                             imageRequestOptions: PHImageRequestOptions? = nil,
                             livePhotoRequestOptions: PHLivePhotoRequestOptions? = nil,
                             exportPreset: String = AVAssetExportPresetHighestQuality,
                             convertLivePhotosToJPG: Bool = false,
                             progressBlock: ((Double) -> Void)? = nil,
                             completionBlock: @escaping ((URL, String) -> Void)) {
        switch mediaType {
        case .image:
            do {
                guard let resource = (PHAssetResource.assetResources(for: self)
                    .filter({ $0.type == .photo })).first else { return }

                var url = FileManager.default.temporaryDirectory.appendingPathComponent("\(resource.originalFilename)")
                if ext == "gif" {
                    PHAssetResourceManager().requestData(for: resource, options: nil) { data in
                        try? data.write(to: url)
                    } completionHandler: { _ in
                        DispatchQueue.main.async {
                            completionBlock(url, "image/gif")
                        }
                    }
                    return
                }

                var options = PHImageRequestOptions()
                if let imageRequestOptions {
                    options = imageRequestOptions
                } else {
                    options.isNetworkAccessAllowed = true
                    options.isSynchronous = true
                    options.resizeMode = .none
                    options.isNetworkAccessAllowed = true
                    options.version = .current
                }

                options.progressHandler = { (progress, _, _, _) in
                    DispatchQueue.main.async {
                        progressBlock?(progress)
                    }
                }

                var image: UIImage?
                _ = PHImageManager.default().requestImageDataAndOrientation(for: self, options: options) {
                    (imageData, _, _, _) in
                    if let data = imageData {
                        image = UIImage(data: data)
                    }
                }

                guard let image,
                      let data = image.withFixedOrientation.jpegData(compressionQuality: 0.8) else { return }
                url = url.deletingPathExtension().appendingPathExtension("jpeg")
                let mimetype = "image/jpeg"
                try data.write(to: url)
                DispatchQueue.main.async {
                    completionBlock(url, mimetype)
                }
            } catch {}
        default:
            guard let resource = (PHAssetResource.assetResources(for: self).filter {
                $0.type == PHAssetResourceType.video }).first else { return }

            let localURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                               isDirectory: true).appendingPathComponent(resource.originalFilename)
            let mimeType = localURL.mimeType

            var options = PHVideoRequestOptions()
            if let videoRequestOptions {
                options = videoRequestOptions
            } else {
                options.isNetworkAccessAllowed = true
            }

            options.progressHandler = { (progress, _, _, _) in
                DispatchQueue.main.async {
                    progressBlock?(progress)
                }
            }

            PHImageManager.default().requestExportSession(forVideo: self,
                                                          options: options,
                                                          exportPreset: exportPreset) { (session, _) in
                session?.outputURL = localURL
                session?.outputFileType = AVFileType.mov
                session?.exportAsynchronously(completionHandler: {
                    DispatchQueue.main.async {
                        completionBlock(localURL, mimeType)
                    }
                })
            }
        }
    }
}
