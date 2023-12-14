//
//  FavouritesController.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import UIKit
import CoreData

class FavouritesController: BaseViewController, Storyboardable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var favouriteMovieService: FavouriteMovieServiceProtocol!
    var visitedHistoryService: VisitedHistoryServiceProtocol!

    private var visitHistoryDict = [Int32: VisitHistory]()

    private lazy var fetchedResultsController: NSFetchedResultsController<FavouriteMovie> = {
        let request = FavouriteMovie.fetchRequest()
        let sort = NSSortDescriptor(key: "favouriteDate", ascending: false)
        request.sortDescriptors = [sort]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: CoreDataManager.shared.managedContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: "FavouriteMovies")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    private let emptyMessageLabel: UILabel = {
        UILabel(text: "You don't have any favourite movies",
                font: .systemFont(ofSize: 16),
                textColor: .secondaryLabel,
                textAlignment: .center,
                numberOfLines: 0,
                lineBreakMode: .byWordWrapping,
                isHidden: true)
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchVisitedHistories()
        tableView.reloadData()
    }

    private func fetchVisitedHistories() {
        let visitHistories = visitedHistoryService.getVistedHistories() ?? []
        visitHistoryDict = visitHistories.reduce(into: [:]) { $0[$1.trackId] = $1 }
    }
    
    // MARK: - Helpers
    private func showMovieDetails(atIndexPath indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) as? MovieCell else {
            return
        }

        let movieDetailType = MovieDetailType.favouriteMovie(fetchedResultsController.object(at: indexPath))
        
        visitedHistoryService.updateVisitedHistory(forTrackId: movieDetailType.trackId,
                                                   visitHistory: visitHistoryDict[Int32(movieDetailType.trackId)])

        let movieDetailsController = MovieDetailsController(thumbnailImage: cell.movieImageView.image ?? .placeholder,
                                                            visitHistory: visitHistoryDict[Int32(movieDetailType.trackId)],
                                                            movieDetailType: movieDetailType,
                                                            favouriteMovieService: favouriteMovieService)
        movieDetailsController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(movieDetailsController, animated: true)
    }

    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(emptyMessageLabel)
        emptyMessageLabel.anchor(leading: view.leadingAnchor,
                                 trailing: view.trailingAnchor,
                                 centerY: view.centerYAnchor)
    }
    
    override func setupUI() {
        super.setupUI()

        setupTableView()
    }
}

// MARK: - Helpers
extension FavouritesController {
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
        let numberOfItem = fetchedResultsController.sections![section].numberOfObjects
        emptyMessageLabel.isHidden = !(numberOfItem == 0)
        return numberOfItem
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as? MovieCell else {
            fatalError("Unsupported cell")
        }
        
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: 0) - 1
        let leftInset = isLastRow ? 0.0 : 16
        let rightInset = isLastRow ? tableView.frame.width : 0
        cell.separatorInset = .init(top: 0, left: leftInset, bottom: 0, right: rightInset)
        configure(cell: cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showMovieDetails(atIndexPath: indexPath)
    }

    private func configure(cell: MovieCell, at indexPath: IndexPath) {
        let favouriteMovie = fetchedResultsController.object(at: indexPath)
        let viewModel = MovieCellViewModel(with: favouriteMovie,
                                           isFavourite: true,
                                           lastVisitedDate: visitHistoryDict[favouriteMovie.trackId]?.visitedDate)
        cell.configure(with: viewModel)
        cell.delegate = self
    }
}

// MARK: - MovieCellDelegate
extension FavouritesController: MovieCellDelegate {
    func movieCellDidPressedFavourite(_ cell: MovieCell, isFavourite: Bool) {
        if !isFavourite {
            guard let indexPath = tableView.indexPath(for: cell) else {
                return
            }

            favouriteMovieService.deleteFavouriteMovie(movie: fetchedResultsController.object(at: indexPath))
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension FavouritesController: NSFetchedResultsControllerDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

