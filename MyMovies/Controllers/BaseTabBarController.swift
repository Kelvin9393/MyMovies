//
//  BaseTabBarController.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import UIKit

class BaseTabBarController: UITabBarController, Storyboardable {

    enum TabBarItem: CaseIterable {
        case movies, search, favourites

        var title: String {
            return String(describing: self).capitalized
        }

        var icon: String {
            switch self {
            case .movies: return "film"
            case .search: return "magnifyingglass"
            case .favourites: return "heart.fill"
            }
        }
    }

    var movieService: MovieServiceProtocol!
    var appService: AppServiceProtocol!
    var favouriteMovieService: FavouriteMovieServiceProtocol!
    var visitedHistoryService: VisitedHistoryServiceProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        setupViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        selectedIndex = appService.getLastSelectedTab()
    }

    private func setupViewControllers() {
        var controllers = [UIViewController]()
        TabBarItem.allCases.forEach { item in

            let controller: UIViewController

            switch item {
            case .movies:
                let moviesVC = MoviesController.instantiate()
                moviesVC.movieService = movieService
                moviesVC.favouriteMovieService = favouriteMovieService
                moviesVC.visitedHistoryService = visitedHistoryService
                controller = UINavigationController(rootViewController: moviesVC)
            case .search:
                let searchVC = SearchController.instantiate()
                searchVC.movieService = movieService
                searchVC.favouriteMovieService = favouriteMovieService
                searchVC.visitedHistoryService = visitedHistoryService
                controller = UINavigationController(rootViewController: searchVC)
            case .favourites:
                let favouritesVC = FavouritesController.instantiate()
                favouritesVC.favouriteMovieService = favouriteMovieService
                favouritesVC.visitedHistoryService = visitedHistoryService
                controller = UINavigationController(rootViewController: favouritesVC)
            }

            controller.tabBarItem = UITabBarItem(title: item.title, image: UIImage(systemName: item.icon), selectedImage: nil)
            controllers.append(controller)
        }

        viewControllers = controllers
    }
}

// MARK: - UITabBarControllerDelegate
extension BaseTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = viewControllers?.firstIndex(of: viewController) {
            appService.setLastSelectedTab(tabIndex: index)
        }
        
        return true
    }
}
