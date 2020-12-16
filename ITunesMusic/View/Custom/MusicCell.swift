//
//  MusicCell.swift
//  ITunesMusic
//
//  Created by Manh Blue on 11/26/20.
//  Copyright © 2020 Manh Blue. All rights reserved.
//

import UIKit

final class MusicCell: UITableViewCell {
    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var artistImageView: UIImageView!
    
    let downloaded = Downloaded.shared
    static let identifier = "MusicCell"
    var indexPath: IndexPath?
    var downloadService = DownloadService()
    var delegate: MusicViewController? {
        didSet {
            downloadService.session = URLSession(configuration: URLSessionConfiguration.default, delegate: delegate, delegateQueue: OperationQueue())
        }
    }
    
    var music: Music = Music()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupButton()
        setupDownloadProgess()
        configArtistImageView()
        configMusicnameLabel()
    }
    
    func loadMusic(with music: Music) {
        self.music = music
        musicNameLabel.text = music.musicName
        artistNameLabel.attributedText = NSAttributedString.artist(music.artistName)

        if let image = downloaded.imageOfUrl[music.previewUrl!] {
            artistImageView.image = image
            return
        } else {
            artistImageView.image = nil
        }
        
        DispatchQueue.main.async {
            DispatchQueue.global(qos: .default).async {
                if let url = music.imageUrl, let data = try? Data(contentsOf: url) {
                    self.music.imageData = data
                    DispatchQueue.main.sync {
                        self.artistImageView.image = UIImage(data: data)!
                    }
                }
            }
        }
    }
    
    private func configArtistImageView() {
        artistImageView.layer.masksToBounds = true
        artistImageView.contentMode = .scaleAspectFill
        artistImageView.layer.cornerRadius = 8
    }
    
    private func configMusicnameLabel() {
        musicNameLabel.layer.masksToBounds = true
        musicNameLabel.layer.cornerRadius = 8
    }
    
    private func setupDownloadProgess() {
        downloadProgressView.tintColor = .red
        downloadProgressView.progress = 0.1
    }
    
    private func setupButton() {
        downloadButton.setTitle(nil, for: .normal)
        downloadButton.setAttributedTitle(NSAttributedString.download, for: .normal)
        downloadButton.isHidden = true
        downloadProgressView.isHidden = true
    }
    
    @IBAction func clickDownload(_ sender: Any) {
        if music.localPath != nil {
            return
        }
        delegate?.indexPathDownloadedCell = indexPath
        downloadService.download(music: music)
    }
}
