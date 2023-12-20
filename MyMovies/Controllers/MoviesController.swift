//
//  MoviesController.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import UIKit

class MoviesController: BaseViewController, Storyboardable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var movieService: MovieServiceProtocol!
    var favouriteMovieService: FavouriteMovieServiceProtocol!
    var visitedHistoryService: VisitedHistoryServiceProtocol!

    private var movies = [Movie]()
    private var favouriteMovieDict = [Int32: FavouriteMovie]()
    private var visitHistoryDict: [Int32: VisitHistory] = [:]
    private var isFirstAppear = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationController?.navigationItem.largeTitleDisplayMode = .always
        fetchAllMovies()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !isFirstAppear {
            fetchFavouriteMoviesAndVisitedHistories()
            tableView.reloadData()
        }

        isFirstAppear = false
    }
    
    // MARK: - APIs
    private func fetchAllMovies() {
        activityIndicator.startAnimating()
        movieService.getAllMovies { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.activityIndicator.stopAnimating()

            switch result {
            case .success(let response):
                self.movies = response.results ?? []
                self.fetchFavouriteMoviesAndVisitedHistories()
                self.tableView.reloadData()
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }

    private func fetchFavouriteMovies() {
        let favouriteMovies = favouriteMovieService.getFavouriteMovies() ?? []
        favouriteMovieDict = favouriteMovies.reduce(into: [:]) { $0[$1.trackId] = $1 }
    }

    private func fetchVisitedHistories() {
        let visitHistories = visitedHistoryService.getVistedHistories() ?? []
        visitHistoryDict = visitHistories.reduce(into: [:]) { $0[$1.trackId] = $1 }
    }

    private func fetchFavouriteMoviesAndVisitedHistories() {
        fetchFavouriteMovies()
        fetchVisitedHistories()
    }

    // MARK: - Helpers
    private func showMovieDetails(atIndexPath indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) as? MovieCell else {
            return
        }

        let trackId = Int32(movies[indexPath.row].trackId)
        let movieType: MovieDetailType

        if cell.isFavourite {
            guard let favouriteMovie = favouriteMovieDict[trackId] else {
                return
            }

            movieType = .favouriteMovie(favouriteMovie)
        } else {
            movieType = .movie(movies[indexPath.row])
        }

        visitedHistoryService.updateVisitedHistory(forTrackId: trackId, visitHistory: visitHistoryDict[trackId])

        let movieDetailsController = MovieDetailsController(thumbnailImage: cell.movieImageView.image ?? .placeholder,
                                                            visitHistory: visitHistoryDict[Int32(trackId)],
                                                            movieDetailType: movieType,
                                                            favouriteMovieService: favouriteMovieService)
        movieDetailsController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(movieDetailsController, animated: true)
    }

    override func setupLayout() {
        super.setupLayout()
    }
    
    override func setupUI() {
        super.setupUI()

        navigationController?.navigationBar.prefersLargeTitles = true
        setupTableView()
    }
}

// MARK: - Helpers
extension MoviesController {
    private func setupTableView() {
        let cellNib = UINib(nibName: MovieCell.identifier, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: MovieCell.identifier)

        // Hide separator above first row
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
        let trackId = Int32(movie.trackId)
        let viewModel = MovieCellViewModel(with: movie,
                                           isFavourite: favouriteMovieDict[trackId] != nil,
                                           lastVisitedDate: visitHistoryDict[trackId]?.visitedDate)
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
        let trackId = Int32(movie.trackId)
        if isFavourite {
            favouriteMovieService.addNewFavouriteMovie(movie: movie,
                                                       movieImageData: cell.movieImageView.image?.pngData(),
                                                       visitHistory: visitHistoryDict[trackId])
        } else {
            guard let favouriteMovie = favouriteMovieDict[trackId] else {
                return
            }

            favouriteMovieService.deleteFavouriteMovie(movie: favouriteMovie)
        }

        fetchFavouriteMovies()
    }
}

