//
//  MovieCell.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import UIKit
import Nuke

protocol MovieCellDelegate: AnyObject {
    func movieCellDidPressedFavourite(_ cell: MovieCell, isFavourite: Bool)
}

class MovieCell: UITableViewCell {
    
    static let identifier = "MovieCell"
    
    // MARK: - IBOutlets
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var visitedDateLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: MovieCellDelegate?
    
    private(set) var isFavourite = false {
        didSet {
            favouriteButton.setImage(isFavourite ? .isFavourite : .notFavourite, for: .normal)
        }
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        movieImageView.layer.borderColor = UIColor.opaqueSeparator.cgColor
        movieImageView.tintColor = .secondaryLabel
        movieImageView.layer.borderWidth = 0.5
        
        favouriteButton.imageView?.anchorSize(to: favouriteButton)
        favouriteButton.imageView?.contentMode = .scaleAspectFit
    }
    
    // MARK: IBActions
    
    @IBAction func favouriteButtonTapped(_ sender: Any) {
        isFavourite.toggle()
        delegate?.movieCellDidPressedFavourite(self, isFavourite: isFavourite)
    }
    
    // MARK: - Helpers
    
    func configure(with viewModel: MovieCellViewModel) {
        switch viewModel.thumbnail {
        case .imageUrl(let url):
            movieImageView.loadImage(with: url, ofSize: .init(width: 60, height: 90),
                                     placeholder: .placeholder,
                                     failureImage: .placeholder,
                                     contentModes: .init(success: .scaleAspectFit,
                                                         failure: .scaleAspectFit,
                                                         placeholder: .scaleAspectFit))
        case .imageData(let data):
            movieImageView.image = UIImage(data: data) ?? .placeholder
        case .imageFilePath(let path):
            movieImageView.image = UIImage(contentsOfFile: path) ?? .placeholder
        case .none:
            movieImageView.image = .placeholder
        }
        
        titleLabel.text = viewModel.title
        genreLabel.text = viewModel.genre
        visitedDateLabel.text = viewModel.lastVisited
        priceLabel.text = viewModel.price
        favouriteButton.setImage(viewModel.favouriteImage, for: .normal)
        isFavourite = viewModel.isFavourite
    }
}
