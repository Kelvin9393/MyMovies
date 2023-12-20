//
//  MovieDetailsController.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 08/01/2023.
//

import UIKit

enum MovieDetailType {
    case movie(Movie)
    case favouriteMovie(FavouriteMovie)

    var trackId: Int32 {
        switch self {
        case .movie(let movie):
            return Int32(movie.trackId)
        case .favouriteMovie(let favouriteMovie):
            return favouriteMovie.trackId
        }
    }
}

class MovieDetailsController: BaseViewController {
    
    enum Section: CaseIterable {
        case header, basicInfo, description
    }
    
    // MARK: - Properties
    var favouriteMovieService: FavouriteMovieServiceProtocol!

    private let thumbnailImage: UIImage
    private var movieDetailType: MovieDetailType
    private let tempMovie: Movie?
    private let visitHistory: VisitHistory?
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero)
        tv.separatorStyle = .none
        tv.allowsSelection = false
        tv.showsVerticalScrollIndicator = false
        tv.contentInsetAdjustmentBehavior = .never
        tv.backgroundColor = .systemBackground
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    // MARK: - Lifecycle

    init(thumbnailImage: UIImage,
         visitHistory: VisitHistory?,
         movieDetailType: MovieDetailType,
         favouriteMovieService: FavouriteMovieServiceProtocol) {
        self.favouriteMovieService = favouriteMovieService
        self.thumbnailImage = thumbnailImage
        self.visitHistory = visitHistory
        self.movieDetailType = movieDetailType

        switch movieDetailType {
        case .movie(let movie):
            tempMovie = movie
        case .favouriteMovie(let favouriteMovie):
            tempMovie = favouriteMovie.toModel()
        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var navigationBarShadow: UIImage?
    private var navigationBarBackground: UIImage?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationBarShadow = navigationController?.navigationBar.shadowImage
        navigationBarBackground = navigationController?.navigationBar.backIndicatorImage

        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.shadowImage = navigationBarShadow
        navigationController?.navigationBar.setBackgroundImage(navigationBarBackground, for: .default)
    }

    // MARK: - CoreData

    private func favouriteMovie() {
        switch movieDetailType {
        case .movie(let movie):
            if let favouriteMovie = favouriteMovieService.addNewFavouriteMovie(movie: movie,
                                                                               movieImageData: thumbnailImage.pngData(),
                                                                               visitHistory: visitHistory) {
                movieDetailType = .favouriteMovie(favouriteMovie)
            }
        default:
            break
        }
    }

    private func unfavouriteMovie() {
        switch movieDetailType {
        case .favouriteMovie(let favouriteMovie):
            favouriteMovieService.deleteFavouriteMovie(movie: favouriteMovie)
            guard let movie = tempMovie else {
                return
            }

            movieDetailType = .movie(movie)
        default:
            break
        }
    }
    
    // MARK: - Helpers
    override func setupLayout() {
        super.setupLayout()

        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    override func setupUI() {
        super.setupUI()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MovieDetailsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section.allCases[indexPath.row] {
        case .header:
            let cell = MovieDetailsHeaderCell()
            cell.configure(with: movieDetailType, thumbnailImage: thumbnailImage)
            return cell
        case .basicInfo:
            let cell = MovieDetailsBasicInfoCell()
            cell.configure(with: movieDetailType)
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cell = tableView.cellForRow(at: [0, 0]) as? MovieDetailsHeaderCell {
            cell.handleScrollViewDidScrolled(offsetY: scrollView.contentOffset.y)
        }
    }
}

// MARK: - MovieDetailsBasicInfoCellDelegate
extension MovieDetailsController: MovieDetailsBasicInfoCellDelegate {
    func movieDetailsBasicInfoCellDidPressedBuy(_ cell: MovieDetailsBasicInfoCell) {
        let trackViewUrl: String?
        
        switch movieDetailType {
        case .movie(let movie):
            trackViewUrl = movie.trackViewUrl
        case .favouriteMovie(let favouriteMovie):
            trackViewUrl = favouriteMovie.trackViewUrl
        }
        
        if let trackViewUrl = trackViewUrl,
            let url = URL(string: trackViewUrl),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func movieDetailsBasicInfoCellDidPressedFavourite(_ cell: MovieDetailsBasicInfoCell, isFavourite: Bool) {
        isFavourite ? favouriteMovie() : unfavouriteMovie()
    }
}
