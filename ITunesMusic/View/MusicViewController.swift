//
//  ViewController.swift
//  ITunesMusic
//
//  Created by Manh Blue on 11/25/20.
//  Copyright © 2020 Manh Blue. All rights reserved.
//

import UIKit
import AVKit

final class MusicViewController: UIViewController {
    enum ViewOption {
        case itunes
        case downloads
    }
    
    static let identifier = "MusicViewController"
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView?
    
    var viewOption: ViewOption = .itunes
    private var musicList = MusicList()
    private var downloadedMusicList = MusicList()
    private let queryService = QueryService()
    var indexPathDownloadedCell: IndexPath?
    var downloaded = Downloaded.shared
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        downloaded.syncMusicData()
        print(downloaded.imageOfUrl.keys)
        configTableViewResoucre()
        configFrontSizeView()
        setupSearchBar()
    }
    
    private func itunesReloadData(_ musicList: MusicList) {
        DispatchQueue.main.async {
            self.musicList = musicList
            self.tableView?.reloadData()
        }
    }
    
    private func downloadsReloadData() {
        musicList.music = Array(downloaded.musicOfUrl.values)
        tableView?.reloadData()
    }
    
    private func configTableViewResoucre() {
		
        tableView?.dataSource = self
        tableView?.delegate = self
		
		
        if viewOption == .downloads {
            debugPrint(downloaded.musicOfUrl.values)
            musicList.music = Array(downloaded.musicOfUrl.values)
            downloadedMusicList = musicList
        }
    }
    
    private func configFrontSizeView() {
        tableView?.rowHeight = 80
        view.backgroundColor = .systemPurple
        searchBar.searchTextField.backgroundColor = .white
        UISearchBar.appearance().barTintColor = .systemPurple
    }
    
    private func setupSearchBar() {
        searchBar.searchTextField.placeholder = "Song name or artist name"
        searchBar.searchTextField.addTarget(self, action: #selector(searchTextFieldDidChange), for: .editingChanged)
    }
    
    @objc private func searchTextFieldDidChange() {
        if viewOption == .itunes {
            itunesSearch()
        } else {
            playlistSearch()
        }
    }
    
    private func showErrorAlert(message: String) {
		
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        queryService.cancelTaskIfNeed()
        present(errorAlert, animated: true)
    }
}

//MARK: TableView: dataSource and delegate
extension MusicViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(musicList.music.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if musicList.music.count == 0 {
            let cell = UITableViewCell()
            cell.textLabel!.text = searchBar.searchTextField.text!.isEmpty ? "" : "No result"
            tableView.separatorStyle = .none
            return cell
        }
        
        tableView.separatorStyle = .singleLine
        let cell = tableView.dequeueReusableCell(withIdentifier: MusicCell.identifier, for: indexPath) as! MusicCell
        let music = musicList.music[indexPath.row]
        cell.loadMusic(with: music)
        cell.delegate = self
        cell.indexPath = indexPath
        
        if viewOption == .downloads {
            cell.downloadButton.isHidden = true
            return cell
        }
        print("119 ", music)
        cell.downloadButton.isHidden = false
        if downloaded.checkExist(music) {
            cell.downloadButton.setAttributedTitle(Attribute.downloaded, for: .normal)
        } else {
            cell.downloadButton.setAttributedTitle(Attribute.download, for: .normal)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? MusicCell else { return }
        if cell.music.localPath != nil {
            MusicPlayer.playDownload(music: cell.music, on: self)
        }
    }
}

//MARK: URLSessionDelegate
extension MusicViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        
        guard let url = downloadTask.originalRequest?.url else { return }
        let fileManager = FileManager.default
        let docsPath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let destinationPath = docsPath.appendingPathComponent(url.lastPathComponent)
        
        try? fileManager.removeItem(at: destinationPath)
        
        do {
            try fileManager.copyItem(at: location, to: destinationPath)
            DispatchQueue.main.sync {
                let cell = tableView?.cellForRow(at: indexPathDownloadedCell!) as! MusicCell
                cell.music.localPath = destinationPath
                debugPrint("location: ", destinationPath)
                downloaded.add(music: cell.music)
                downloaded.syncMusicData()
                (self.tabBarController!.viewControllers![1] as! MusicViewController).downloadsReloadData()
            }
                    
        } catch let error {
          print("136 Copy error: \(error.localizedDescription)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {

        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        DispatchQueue.main.sync {
            let cell = self.tableView?.cellForRow(at: indexPathDownloadedCell!) as! MusicCell
            cell.downloadProgressView.isHidden = false
            cell.downloadProgressView.progress = progress
            if progress == 1 {
                cell.downloadProgressView.isHidden = true
                cell.downloadButton.setAttributedTitle(Attribute.downloaded, for: .normal)
                cell.downloadButton.isEnabled = true
            }
        }
    }
}

//MARK: View option function
extension MusicViewController {
    private func itunesSearch() {
        indexPathDownloadedCell = nil
        let searchText = self.searchBar.searchTextField.text!
        if searchText.isEmpty { return }
        
        queryService.cancelTaskIfNeed()
        queryService.getMusicInfo(term: searchText) { result in
            switch result {
            case .success(let musicList):
                self.itunesReloadData(musicList)
            case .failure(let errorMessage):
                // ShowAlert
                self.showErrorAlert(message: errorMessage.content)
            }
        }
    }
    
    private func playlistSearch() {
        musicList.music = downloadedMusicList.music.filter {
            let searchText = searchBar.searchTextField.text!
            let searchTextFormat = searchText.trim().folding.uppercased()
            let musicName = $0.musicName.folding.uppercased()
            let artistName = $0.artistName.folding.uppercased()
            return artistName.contains(searchTextFormat) || musicName.contains(searchTextFormat) || searchTextFormat.isEmpty
        }
        tableView?.reloadData()
    }
}
