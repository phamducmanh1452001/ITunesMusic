//
//  AppDelegate.swift
//  ITunesMusic
//
//  Created by Manh Blue on 11/25/20.
//  Copyright © 2020 Manh Blue. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NetWorkMonitor.shared.startMonitoring()
        setRoot(tabBarViewController())
        return true
    }
    
    private func tabBarViewController() -> UITabBarController {
        let tabBar = UITabBarController()
        let itunesVC = musicViewController()
        let downloadsVC = musicViewController()
        downloadsVC.viewOption = .downloads
        //UserDefaults.standard.set(nil, forKey: "DownloadedMusic")
        //UserDefaults.standard.set(nil, forKey: "DownloadedImage")
        itunesVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        itunesVC.title = "Itunes"
        downloadsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 1)
        downloadsVC.title = "Downloads"
        tabBar.viewControllers = [itunesVC, downloadsVC]
        return tabBar
    }
    
    private func musicViewController() -> MusicViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let musicViewController = storyBoard.instantiateViewController(
            identifier: MusicViewController.identifier) as! MusicViewController
        return musicViewController
    }
    
    private func setRoot(_ vc: UIViewController) {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}

