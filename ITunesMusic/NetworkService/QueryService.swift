//
//  QueryService.swift
//  ITunesMusic
//
//  Created by Manh Blue on 11/26/20.
//  Copyright © 2020 Manh Blue. All rights reserved.
//

import UIKit

struct QueryService {
    private let baseURL = "https://itunes.apple.com/search"
    private let session = URLSession(configuration: .default)
    private static var isCompleted = true
    private static var resumeTask: URLSessionDataTask?
	

    
    func getMusicInfo(term: String, completion: @escaping (Result<MusicList, ErrorMessage>) -> Void ) {
        if !NetWorkMonitor.shared.isConnected {
            completion(.failure(ErrorMessage("No internet")))
        }
        if !QueryService.isCompleted { return }
        QueryService.isCompleted = false

        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.query = "media=music&entity=song&term=\(term)"
        
        guard let url = urlComponents?.url else { return }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let errorMessage = error {
                if errorMessage.localizedDescription == "cancelled" {
                    QueryService.isCompleted = true
                    return
                }
                completion(.failure(ErrorMessage("0" + errorMessage.localizedDescription)))
                QueryService.isCompleted = true
                return
            }
            
            guard let data = data else {
                completion(.failure(ErrorMessage("Data error from server")))
                QueryService.isCompleted = true
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...300).contains(httpResponse.statusCode) {
                    completion(.failure(ErrorMessage("2" + httpResponse.description)))
                    QueryService.isCompleted = true
                    return
                }
            }
            
            do {
                let musicList = try JSONDecoder().decode(MusicList.self, from: data)
                completion(.success(musicList))
                QueryService.isCompleted = true
            } catch {
                completion(.failure(ErrorMessage("Data error from server")))
                QueryService.isCompleted = true
            }
        }
        
        task.resume()
        QueryService.resumeTask = task
    }
    
    func cancelTaskIfNeed() {
        QueryService.resumeTask?.cancel()
        QueryService.resumeTask = nil
    }
}
