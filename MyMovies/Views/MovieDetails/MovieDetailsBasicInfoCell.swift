//
//  MovieDetailsBasicInfoCell.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 08/01/2023.
//

import UIKit

protocol MovieDetailsBasicInfoCellDelegate: AnyObject {
    func movieDetailsBasicInfoCellDidPressedBuy(_ cell: MovieDetailsBasicInfoCell)
    func movieDetailsBasicInfoCellDidPressedFavourite(_ cell: MovieDetailsBasicInfoCell, isFavourite: Bool)
    func movieDetailsBasicInfoCellDidPressedTrailer(_ cell: MovieDetailsBasicInfoCell)
}

class MovieDetailsBasicInfoCell: BaseTableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: MovieDetailsBasicInfoCellDelegate?
    
    private var isFavourite = false {
        didSet {
            favouriteButton.setImage(isFavourite ? .isFavourite : .notFavourite, for: .normal)
        }
    }
    
    private let titleLabel: UILabel = {
        UILabel(font: .systemFont(ofSize: 24, weight: .bold), numberOfLines: 0, lineBreakMode: .byWordWrapping, adjustsFontSizeToFitWidth: true)
    }()
    
    private let artistNameLabel: UILabel = {
        UILabel(font: .systemFont(ofSize: 14, weight: .semibold), textColor: .label, adjustsFontSizeToFitWidth: true)
    }()
    
    private let releaseDateLabel: UILabel = {
        UILabel(font: .systemFont(ofSize: 14), textColor: .secondaryLabel)
    }()
    
    private let separatorDotLabel: UILabel = {
        UILabel(text: "•", font: .systemFont(ofSize: 14), textColor: .secondaryLabel)
    }()
    
    private let genreLabel: UILabel = {
        UILabel(font: .systemFont(ofSize: 14), textColor: .secondaryLabel)
    }()
    
    private lazy var purchaseButton: UIButton = {
        let button = UIButton(title: "", titleColor: .systemBackground, font: .systemFont(ofSize: 14, weight: .semibold), backgroundColor: .label, target: self, action: #selector(handleBuyButtonTapped))
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.cornerRadius = 8
        return button
    }()
    
    private lazy var favouriteButton: UIButton = {
        let button = UIButton(image: .notFavourite, tintColor: .label, target: self, action: #selector(handleFavouriteButtonTapped))
        button.imageView?.anchorSize(to: button)
        return button
    }()
    
    private let aboutMovieTitleLabel: UILabel = {
        UILabel(text: "About the Movie", font: .systemFont(ofSize: 14), textColor: .label)
    }()
    
    private let aboutMovieDescriptionLabel: UILabel = {
        UILabel(font: .systemFont(ofSize: 13), textColor: .secondaryLabel, numberOfLines: 0)
    }()

    private let trailerTitleLabel: UILabel = {
        UILabel(text: "Watch the Trailer", font: .systemFont(ofSize: 18, weight: .bold), textColor: .label)
    }()

    lazy var trailerButton: UIButton = {
        let button = UIButton(configuration: .borderless(), image: UIImage(), backgroundColor: .black, isHidden: false, target: self, action: #selector(handleTrailerPressed))
        button.clipsToBounds = true
        button.layer.cornerRadius = 8
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.opaqueSeparator.cgColor
        return button
    }()
    
    // MARK: - Selectors
    
    @objc private func handleBuyButtonTapped() {
        delegate?.movieDetailsBasicInfoCellDidPressedBuy(self)
    }
    
    @objc private func handleFavouriteButtonTapped(sender: UIButton) {
        isFavourite.toggle()
        delegate?.movieDetailsBasicInfoCellDidPressedFavourite(self, isFavourite: isFavourite)
    }
    
    // MARK: - Helpers
    
    func configure(with movieType: MovieDetailType, trailerImage: UIImage) {
        let movie: MovieDisplayable
        
        switch movieType {
        case .movie(let regularMovie):
            movie = regularMovie
            isFavourite = false
        case .favouriteMovie(let favouriteMovie):
            movie = favouriteMovie
            isFavourite = true
        }
        
        titleLabel.text = movie.name
        
        if let artistName = movie.artistName {
            artistNameLabel.text = "By \(artistName)"
        } else {
            artistNameLabel.isHidden = true
        }
        
        releaseDateLabel.text = movie.strReleaseDate
        genreLabel.text = movie.genre
        aboutMovieDescriptionLabel.text = movie.longDescription
        
        if let price = movie.price {
            purchaseButton.setTitle("Buy \(movie.currency ?? "$")\(String(format: "%.2f", price))", for: .normal)
        } else {
            purchaseButton.isHidden = true
        }

        trailerButton.setImage(trailerImage, for: .normal)
    }

    @objc private func handleTrailerPressed() {
        delegate?.movieDetailsBasicInfoCellDidPressedTrailer(self)
    }
    
    override func setupViews() {
        super.setupViews()

        contentView.isUserInteractionEnabled = false
        
        hstack(UIView().withWidth(16),
               UIView().vstack(UIView().vstack(UIView().withHeight(8),
                                               titleLabel,
                                               artistNameLabel,
                                               UIView().hstack(genreLabel,
                                                               separatorDotLabel,
                                                               releaseDateLabel,
                                                               spacing: 6,
                                                               alignment: .center),
                                               UIView().withHeight(12),
                                               spacing: 6,
                                               alignment: .leading),
                               UIView().vstack(UIView().hstack(purchaseButton.withWidth(160),
                                                               favouriteButton.withSize(.init(width: 30, height: 30)),
                                                               spacing: 16),
                                               UIView().withHeight(24),
                                               alignment: .leading),
                               UIView().vstack(aboutMovieTitleLabel,
                                               aboutMovieDescriptionLabel,
                                               UIView().withHeight(16),
                                               spacing: 8),
                               UIView().vstack(trailerTitleLabel,
                                               trailerButton,
                                               UIView().withHeight(16),
                                               spacing: 8)
               ),
               UIView().withWidth(16))

        trailerButton.heightAnchor.constraint(equalTo: trailerButton.widthAnchor, multiplier: 3/5).isActive = true
        
    }
}
