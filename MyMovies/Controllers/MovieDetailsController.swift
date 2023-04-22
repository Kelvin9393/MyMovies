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

    var trackId: Int {
        switch self {
        case .movie(let movie):
            return movie.trackId
        case .favouriteMovie(let favouriteMovie):
            return Int(favouriteMovie.trackId)
        }
    }
}

class MovieDetailsController: BaseViewController {
    
    enum Section: CaseIterable {
        case header, basicInfo, description
    }
    
    // MARK: - Properties
    private let thumbnailImage: UIImage
    private var movieDetailType: MovieDetailType
    private let tempMovie: Movie?
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero)
        tv.separatorStyle = .none
        tv.allowsSelection = false
        tv.showsVerticalScrollIndicator = false
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    // MARK: - Lifecycle

    init(thumbnailImage: UIImage, movieDetailType: MovieDetailType) {
        self.thumbnailImage = thumbnailImage
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

    // MARK: - CoreData

    private func favouriteMovie() {
        switch movieDetailType {
        case .movie(let movie):
            SharedData.shared().addNewFavouriteMovie(movie: movie, movieImage: thumbnailImage) { [unowned self] favouriteMovie in
                self.movieDetailType = .favouriteMovie(favouriteMovie)
            }
        default:
            break
        }
    }

    private func unfavouriteMovie() {
        switch movieDetailType {
        case .favouriteMovie(let favouriteMovie):
            SharedData.shared().deleteFavouriteMovie(movie: favouriteMovie) { [weak self] in
                guard let self = self,
                      let movie = self.tempMovie else { return }
                self.movieDetailType = .movie(movie)
            }
        default:
            break
        }
    }
    
    // MARK: - Helpers
    
    override func setupLayout() {
        super.setupLayout()
        
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
