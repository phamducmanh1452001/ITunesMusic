//
//  Extension.swift
//  ITunesMusic
//
//  Created by baonv on 11/27/20.
//  Copyright © 2020 Manh Blue. All rights reserved.
//

import UIKit
import Foundation
import AVKit

typealias Attribute = NSAttributedString
extension NSAttributedString {
    static let download: NSAttributedString = {
        let attributeKey: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.red,
            .font: UIFont.systemFont(ofSize: 12)
        ]
        return NSAttributedString(string: "Download", attributes: attributeKey)
    }()
    
    static let downloaded: NSAttributedString = {
        let attributeKey: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.green,
            .font: UIFont.systemFont(ofSize: 12)
        ]
        return NSAttributedString(string: "Downloaded", attributes: attributeKey)
    }()
    
    static let artist: (String) -> NSAttributedString = { (name: String) in
        let attributeKey: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 15)
        ]
        return NSAttributedString(string: name, attributes: attributeKey)
    }
    
    static let none: NSAttributedString = {
        return NSAttributedString(string: "", attributes: [:])
    }()
}

extension String {
    var folding: String {
        let simple = folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: nil)
        let nonAlphaNumeric = CharacterSet.alphanumerics.inverted
        return simple.components(separatedBy: nonAlphaNumeric).joined(separator: "")
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

typealias MusicPlayer = AVPlayerViewController
extension AVPlayerViewController {
    static func playDownload(music: Music, on viewController: UIViewController) {
      let playerViewController = AVPlayerViewController()
      let width = viewController.width
      //let height = viewController.height
      let imageView = UIImageView(frame: CGRect(x: 10, y: 200, width: width - 20, height: width - 20))
      if let data = try? Data(contentsOf: music.image100pxUrl!) {
          imageView.image = UIImage(data: data)
      }
      imageView.backgroundColor = .red
      playerViewController.contentOverlayView?.addSubview(imageView)
      viewController.present(playerViewController, animated: true, completion: nil)
      let player = AVPlayer(url: music.localPath!)
print(music.localPath!)
      playerViewController.player = player
      player.play()
    }
}

extension UIViewController {
    var height: CGFloat {
        get { return view.frame.height}
    }
    
    var width: CGFloat {
        get { return view.frame.width}
    }
}
