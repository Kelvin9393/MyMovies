//
//  MovieDetailsHeaderCell.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 08/01/2023.
//

import UIKit

class MovieDetailsHeaderCell: BaseTableViewCell {
    
    // MARK: - Properties
    var imageData: Data? {
        headerImageView.image?.pngData()
    }
    
    private let headerImageView: UIImageView = {
        let iv = UIImageView(contentMode: .scaleAspectFit, tintColor: .secondaryLabel, clipsToBounds: true)
        iv.layer.borderColor = UIColor.opaqueSeparator.cgColor
        iv.tintColor = .secondaryLabel
        iv.layer.borderWidth = 0.5
        return iv
    }()
    
    
    // MARK: - Helpers
    func configure(with type: MovieDetailType, thumbnailImage: UIImage?) {
        headerImageView.image = thumbnailImage
        let imageURL: URL
        
        switch type {
        case .movie(let movie):
            guard let url = movie.imageUrl(with: .s600) else {
                headerImageView.image = .placeholder
                return
            }
            
            imageURL = url
        case .favouriteMovie(let favouriteMovie):
            guard let url = URL(string: favouriteMovie.imageUrl ?? "") else {
                headerImageView.image = .placeholder
                return
            }
            
            imageURL = url
        }
        
        headerImageView.loadImage(with: imageURL, placeholder: thumbnailImage ?? .placeholder, failureImage: thumbnailImage ?? .placeholder, contentModes: .init(success: .scaleAspectFit, failure: .scaleAspectFit, placeholder: .scaleAspectFit))
    }
    
    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(headerImageView)
        headerImageView.anchor(top: contentView.topAnchor, bottom: contentView.bottomAnchor, padding: .init(top: 16, left: 0, bottom: 16, right: 0), widthAnchor: contentView.widthAnchor, widthMultiplier: 0.5, heightAnchor: headerImageView.widthAnchor, heightMultiplier: 3/2, centerX: contentView.centerXAnchor)
        
    }
}
