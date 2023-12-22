//
//  MovieDetailsController.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 08/01/2023.
//

import UIKit
import AVKit
import AVFoundation

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
    private var trailerImage: UIImage?
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

    private var avPlayer: AVPlayer?

    private lazy var avPlayerController: AVPlayerViewController = {
        let controller = AVPlayerViewController()
        return controller
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

        navigationBarShadow = navigationController?.navigationBar.shadowImage
        navigationBarBackground = navigationController?.navigationBar.backIndicatorImage

        if let previewURL = URL(string: tempMovie?.previewUrl ?? "") {
            avPlayer = AVPlayer(url: previewURL)
            avPlayerController.player = avPlayer
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var navigationBarShadow: UIImage?
    private var navigationBarBackground: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let previewURL = URL(string: tempMovie?.previewUrl ?? "") {
            AVAsset(url: previewURL).generateThumbnail { trailerImage in
                self.trailerImage = trailerImage
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? MovieDetailsBasicInfoCell {
                    cell.trailerButton.setImage(trailerImage, for: .normal)
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
            cell.configure(with: movieDetailType, trailerImage: trailerImage ?? UIImage())
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

    func movieDetailsBasicInfoCellDidPressedTrailer(_ cell: MovieDetailsBasicInfoCell) {
        present(avPlayerController, animated: true) {
            self.avPlayer?.play()
        }
    }
}

extension AVAsset {
    func generateThumbnail(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let avAssetImageGenerator = AVAssetImageGenerator(asset: self)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumbnailTime = CMTimeMake(value: 20, timescale: 1)

            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
                let thumbNailImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbNailImage)
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
