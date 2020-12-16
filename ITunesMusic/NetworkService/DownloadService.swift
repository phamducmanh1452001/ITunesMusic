//
//  DownloadService.swift
//  ITunesMusic
//
//  Created by Manh Blue on 11/26/20.
//  Copyright © 2020 Manh Blue. All rights reserved.
//

import UIKit

struct DownloadService {
    var session = URLSession(configuration: .default)
    
    func download(music: Music) {
        session.downloadTask(with: music.previewUrl!).resume()
    }
}


class Downloaded {
    static let shared = Downloaded()
    private let defaultKey = "DownloadedMusic"
    private let defaultImageKey = "DownloadedImage"
    var musicOfUrl: [URL: Music] = [:]
    var imageOfUrl: [URL: UIImage] = [:]
    
    func syncMusicData() {
        let defaults = UserDefaults.standard
        
        if musicOfUrl.isEmpty {
            guard let decodedMusicData = defaults.object(forKey: defaultKey) as? [String: String] else { return }
            for (urlStr, musicStr) in decodedMusicData {
                let url = URL(string: urlStr)!
                let music = Music(from: musicStr)
                musicOfUrl[url] = music
            }
            
            guard let decodedImageData = defaults.object(forKey: defaultImageKey) as? [String: Data] else { return }
            for (urlStr, imageData) in decodedImageData {
                let url = URL(string: urlStr)!
                let image = UIImage(data: imageData)
                imageOfUrl[url] = image
            }
        } else {
            var encodedMusicData: [String: String] = [:]
            var encodedImageData: [String: Data] = [:]
            for (url, music) in musicOfUrl {
                encodedMusicData[url.absoluteString] = music.toString()
            }
            for (url, image) in imageOfUrl {
                encodedImageData[url.absoluteString] = image.pngData()
            }
            
            defaults.set(encodedMusicData, forKey: defaultKey)
            defaults.set(encodedImageData, forKey: defaultImageKey)
            defaults.synchronize()
        }
    }
    
    func add(music: Music) {
        musicOfUrl[music.previewUrl!] = music
        imageOfUrl[music.previewUrl!] = UIImage(data: music.imageData!)
    }
    
    func checkExist(_ music: Music) -> Bool {
        return musicOfUrl[music.previewUrl!] != nil
    }
}
