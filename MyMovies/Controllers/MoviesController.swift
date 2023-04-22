//
//  MoviesController.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import UIKit

class MoviesController: BaseViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private lazy var movies = [Movie]()
    
    private var isFirstAppear = true
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstAppear {
            isFirstAppear = false
        } else {
            SharedData.shared().getFavouriteMoviesAndVisitedHistories() {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - APIs
    private func fetchAllMovies() {
        SearchRouter.getAllMovies.send(SearchResponse.self) { [unowned self] result in
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let response):
                self.movies = response.results ?? []
            case .failure(let error):
                print(String(describing: error))
            }
            
            SharedData.shared().getFavouriteMoviesAndVisitedHistories() {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Helpers
    private func showMovieDetails(atIndexPath indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) as? MovieCell else {
            return
        }

        let trackId = movies[indexPath.row].trackId
        let movieType: MovieDetailType

        if cell.isFavourite {
            guard let movieIndex = SharedData.shared().favouriteMovieDict[Int32(trackId)] else {
                return
            }

            let favouriteMovie = SharedData.shared().favouriteMovies[movieIndex]
            movieType = .favouriteMovie(favouriteMovie)
        } else {
            movieType = .movie(movies[indexPath.row])
        }

        SharedData.shared().updateVisitedHistory(forTrackId: movieType.trackId)

        let movieDetailsController = MovieDetailsController(thumbnailImage: cell.movieImageView.image ?? .placeholder,
                                                            movieDetailType: movieType)
        movieDetailsController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(movieDetailsController, animated: true)
    }

    override func setupLayout() {
        super.setupLayout()
    }
    
    override func setupUI() {
        super.setupUI()
        
        setupTableView()
        fetchAllMovies()
        
        let path = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .last?
            .absoluteString
            .replacingOccurrences(of: "file://", with: "")
            .removingPercentEncoding
        
        print("Path: \(path ?? "Not found")")
    }
    
    private func setupTableView() {
        let cellNib = UINib(nibName: MovieCell.identifier, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: MovieCell.identifier)

        /// Hide separator above first row
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = .init(frame: .init(origin: .zero, size: .init(width: 0, height: 16)))
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MoviesController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as? MovieCell else {
            fatalError("Unsupported cell")
        }
        
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: 0) - 1
        let leftInset = isLastRow ? 0.0 : 16
        let rightInset = isLastRow ? tableView.frame.width : 0
        cell.separatorInset = .init(top: 0, left: leftInset, bottom: 0, right: rightInset)
        let movie = movies[indexPath.row]
        let viewModel = MovieCellViewModel(with: movie,
                                           isFavourite: SharedData.shared().favouriteMovieDict[Int32(movie.trackId)] != nil,
                                           lastVisitedDate: SharedData.shared().visitHistoryDict[Int32(movie.trackId)])
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
extension MoviesController: MovieCellDelegate {
    func movieCellDidPressedFavourite(_ cell: MovieCell, isFavourite: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let movie = movies[indexPath.row]
        if isFavourite {
            SharedData.shared().addNewFavouriteMovie(movie: movie, movieImage: cell.movieImageView.image)
        } else {
            guard let favouriteMovie = SharedData.shared().favouriteMovies.first(where: { $0.trackId == movie.trackId}) else {
                return
            }
            
            SharedData.shared().deleteFavouriteMovie(movie: favouriteMovie)
        }
    }
}

