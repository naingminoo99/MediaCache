//
//  File.swift
//  MediaCache
//
//  Created by Ryan  on 9/30/24.
//

import Foundation
import Kingfisher

final class MediaCacheManager: Sendable {
    
    static let shared = MediaCacheManager()
    
    func getCachedImage(key: String) -> URL? {
        if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: key),
           let data = image.jpegData(compressionQuality: 1) {
            do {
                let fileManager = FileManager.default
                let directoryURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURL = directoryURL.appendingPathComponent("TempImages").appendingPathComponent(key)
                try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                try data.write(to: fileURL, options: .atomic)
                return fileURL
            } catch {
                print("Error: \(error)")
                return nil
            }
        }
        return nil
    }
    
    func cacheImage(for key: String, image: KFCrossPlatformImage) {
        ImageCache.default.store(image, forKey: key)
    }
    
    func deleteImage(key: String) {
        ImageCache.default.removeImage(forKey: key)
    }
}

