//
//  SearchController.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import UIKit
import Alamofire

class SearchController: BaseViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var searchRequest: Request?
    
    enum InfoMessageType: CustomStringConvertible {
        case noSearchYet
        case emptyResult(query: String)
        case error(Error)
        case hidden
        
        var description: String {
            switch self {
            case .noSearchYet: return "Start searching your favourite movies"
            case .emptyResult(let query): return "No results found for \"\(query)\""
            case .error(let error): return error.localizedDescription
            case .hidden: return ""
            }
        }
    }
    
    private lazy var movies = [Movie]()
    private var infoMessage = InfoMessageType.noSearchYet {
        didSet {
            if case .hidden = infoMessage {
                infoMessageLabel.isHidden = true
            } else {
                infoMessageLabel.isHidden = false
            }
            
            infoMessageLabel.text = String(describing: infoMessage)
        }
    }
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchBar.placeholder = "Search"
        sc.searchBar.delegate = self
        return sc
    }()
    
    private lazy var infoMessageLabel: UILabel = {
        UILabel(text: String(describing: infoMessage), font: .systemFont(ofSize: 16), textColor: .secondaryLabel, textAlignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    }()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SharedData.shared().getFavouriteMoviesAndVisitedHistories() { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    // MARK: - APIs
    @objc private func searchMovie(with searchTerm: String) {
        searchRequest?.cancel()
        
        if movies.isEmpty {
            activityIndicator.startAnimating()
        }
        
        searchRequest = SearchRouter.search(term: searchTerm).send(SearchResponse.self) { result in
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let response):
                // Handle search text might be cleared out before API return
                guard !(self.searchController.searchBar.text?.isEmpty ?? true) else {
                    self.movies.removeAll()
                    self.tableView.reloadData()
                    self.infoMessage = .noSearchYet
                    return
                }
                
                self.movies = response.results ?? []
                self.tableView.reloadData()
                self.infoMessage = self.movies.isEmpty ? .emptyResult(query: searchTerm) : .hidden
            case .failure(let error):
                print(String(describing: error))
                switch error {
                case .afError(let afError):
                    if afError.isExplicitlyCancelledError {
                        return
                    } else {
                        self.infoMessage = .error(error)
                    }
                default:
                    self.infoMessage = .error(error)
                }
            }
        }
    }
    
    // MARK: - Selectors
    @objc private func performSearch(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text?.trimmingCharacters(in: .whitespaces), !searchTerm.isEmpty else {
            return
        }
        
        searchMovie(with: searchTerm)
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
        
        view.addSubview(infoMessageLabel)
        infoMessageLabel.anchor(leading: view.leadingAnchor, trailing: view.trailingAnchor, centerY: view.centerYAnchor)
    }
    
    override func setupUI() {
        super.setupUI()
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
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
extension SearchController: UITableViewDataSource, UITableViewDelegate {
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
        let viewModel = MovieCellViewModel(with: movie, isFavourite: SharedData.shared().favouriteMovieDict[Int32(movie.trackId)] != nil,
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
extension SearchController: MovieCellDelegate {
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

// MARK: - UISearchResultsUpdating
extension SearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchRequest?.cancel()
        
        guard let searchTerm = searchBar.text,
              !searchTerm.isEmpty else {
            movies.removeAll()
            tableView.reloadData()
            infoMessage = .noSearchYet
            return
        }
        
        infoMessage = .hidden
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.performSearch(_:)), object: searchBar)
        perform(#selector(self.performSearch(_:)), with: searchBar, afterDelay: 0.75)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        
        searchRequest?.cancel()
        
        movies.removeAll()
        tableView.reloadData()
        infoMessage = .noSearchYet
    }
}


