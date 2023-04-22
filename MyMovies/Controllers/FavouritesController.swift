//
//  FavouritesController.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import UIKit
import CoreData

class FavouritesController: BaseViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let emptyMessageLabel: UILabel = {
        UILabel(text: "You don't have any favourite movies", font: .systemFont(ofSize: 16), textColor: .secondaryLabel, textAlignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, isHidden: true)
    }()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SharedData.shared().getFavouriteMoviesAndVisitedHistories() { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Helpers
    private func showMovieDetails(atIndexPath indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) as? MovieCell else {
            return
        }

        let movieDetailType = MovieDetailType.favouriteMovie(SharedData.shared().favouriteMovies[indexPath.row])

        SharedData.shared().updateVisitedHistory(forTrackId: movieDetailType.trackId)

        let movieDetailsController = MovieDetailsController(thumbnailImage: cell.movieImageView.image ?? .placeholder,
                                                            movieDetailType: movieDetailType)
        movieDetailsController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(movieDetailsController, animated: true)
    }

    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(emptyMessageLabel)
        emptyMessageLabel.anchor(leading: view.leadingAnchor, trailing: view.trailingAnchor, centerY: view.centerYAnchor)
    }
    
    override func setupUI() {
        super.setupUI()
        setupTableView()
    }
    
    private func setupTableView() {
        let cellNib = UINib(nibName: MovieCell.identifier, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: MovieCell.identifier)
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = .init(frame: .init(origin: .zero, size: .init(width: 0, height: 16)))
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension FavouritesController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyMessageLabel.isHidden = !SharedData.shared().favouriteMovies.isEmpty
        return SharedData.shared().favouriteMovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as? MovieCell else {
            fatalError("Unsupported cell")
        }
        
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: 0) - 1
        let leftInset = isLastRow ? 0.0 : 16
        let rightInset = isLastRow ? tableView.frame.width : 0
        cell.separatorInset = .init(top: 0, left: leftInset, bottom: 0, right: rightInset)
        
        let favouriteMovie = SharedData.shared().favouriteMovies[indexPath.row]
        let viewModel = MovieCellViewModel(with: favouriteMovie, isFavourite: true, lastVisitedDate: SharedData.shared().visitHistoryDict[favouriteMovie.trackId])
        cell.configure(with: viewModel)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showMovieDetails(atIndexPath: indexPath)
    }
}

// MARK: - MovieCellDelegate
extension FavouritesController: MovieCellDelegate {
    func movieCellDidPressedFavourite(_ cell: MovieCell, isFavourite: Bool) {
        if !isFavourite {
            guard let indexPath = tableView.indexPath(for: cell) else {
                return
            }
            
            SharedData.shared().deleteFavouriteMovie(movie: SharedData.shared().favouriteMovies[indexPath.row]) { [unowned self] in
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

