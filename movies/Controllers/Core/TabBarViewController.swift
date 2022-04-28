//
//  TabBarViewController.swift
//  movies
//
//  Created by Marcin Pawlicki on 14/04/2022.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let homeVC = HomeViewController()
        let searchVC = SearchViewController()
        let libraryVC = LibraryViewController()
        
        homeVC.title = String.localized(key: "screen_names.home")
        searchVC.title = String.localized(key: "screen_names.search")
        libraryVC.title = String.localized(key: "screen_names.library")
        
        homeVC.navigationItem.largeTitleDisplayMode = .always
        searchVC.navigationItem.largeTitleDisplayMode = .always
        libraryVC.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: homeVC)
        let nav2 = UINavigationController(rootViewController: searchVC)
        let nav3 = UINavigationController(rootViewController: libraryVC)


        nav1.navigationBar.tintColor = .primaryGreen
        nav2.navigationBar.tintColor = .primaryGreen
        nav3.navigationBar.tintColor = .primaryGreen
        
        tabBar.tintColor = .primaryGreen
        

        
        nav1.tabBarItem = UITabBarItem(
            title: String.localized(key: "screen_names.home"),
            image: UIImage(systemName: "house"),
            tag: 1
        )
        nav2.tabBarItem = UITabBarItem(
            title: String.localized(key: "screen_names.search"),
            image: UIImage(systemName: "magnifyingglass"),
            tag: 2
        )
        nav3.tabBarItem = UITabBarItem(
            title: String.localized(key: "screen_names.library"),
            image: UIImage(systemName: "film"),
            tag: 3
        )

        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true

        
        setViewControllers([nav1, nav2, nav3], animated: false)
    }
}
