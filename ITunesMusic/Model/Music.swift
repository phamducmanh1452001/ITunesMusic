//
//  Music.swift
//  ITunesMusic
//
//  Created by Manh Blue on 11/26/20.
//  Copyright © 2020 Manh Blue. All rights reserved.
//

import Foundation

struct Music: Decodable {
    var artistName: String = ""
    var musicName: String = ""
    var musicUrl: URL?
    var previewUrl: URL?
    var imageUrl: URL?
    var image100pxUrl: URL?
    var imageData: Data?
    var localPath: URL?

    
    private enum CodingKeys: String, CodingKey {
        case musicName = "trackName"
        case musicUrl = "trackViewUrl"
        case imageUrl = "artworkUrl60"
        case image100pxUrl = "artworkUrl100"
        case artistName = "artistName"
        case previewUrl = "previewUrl"
    }
    
    init() {

    }
    
    init(from string: String) {
        let stringArr = string.components(separatedBy: "\n")
        if stringArr.count != 7 { return }
        artistName = stringArr[0]
        musicName = stringArr[1]
        musicUrl = URL(string: stringArr[2])
        previewUrl = URL(string: stringArr[3])
        imageUrl = URL(string: stringArr[4])
        image100pxUrl = URL(string: stringArr[5])
        localPath = URL(string: stringArr[6])
    }
    
    func toString() -> String {
        let string =
        """
        \(artistName)
        \(musicName)
        \(musicUrl?.absoluteString ?? "")
        \(previewUrl?.absoluteString ?? "")
        \(imageUrl?.absoluteString ?? "")
        \(image100pxUrl?.absoluteString ?? "")
        \(localPath?.absoluteString ?? "")
        """
        return string
    }
}

struct MusicList: Decodable {
    var music: [Music] = []
    
    private enum CodingKeys: String, CodingKey {
        case music = "results"
    }
}
