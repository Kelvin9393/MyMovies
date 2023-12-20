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

    private var backgroundViewConstraints: AnchoredConstraints?

    private var statusBarHeight: CGFloat = {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets.top ?? .zero
    }()

    private let colorBackgroundView: UIView = {
        UIView()
    }()

    private let gradientTransitionBackgroundView: UIView = {
        UIView()
    }()
    
    private let headerImageView: UIImageView = {
        let iv = UIImageView(contentMode: .scaleAspectFit, tintColor: .secondaryLabel, clipsToBounds: false)
        iv.setShadowView(withColor: .black, shadowOffset: .init(width: 0, height: 5), shadowOpacity: 0.5, shadowRadius: 24)
        return iv
    }()

    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear, UIColor.black].map { $0.cgColor }
        gradientLayer.locations = [0, 1]
        gradientLayer.cornerRadius = 0
        gradientLayer.startPoint = .init(x: 0.5, y: 0)
        gradientLayer.endPoint = .init(x: 0.5, y: 1)
        return gradientLayer
    }()
    
    
    // MARK: - Helpers
    func configure(with type: MovieDetailType, thumbnailImage: UIImage?) {
        headerImageView.image = thumbnailImage
        colorBackgroundView.backgroundColor = thumbnailImage?.averageColor

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
        
        headerImageView.loadImage(with: imageURL,
                                  placeholder: thumbnailImage ?? .placeholder,
                                  failureImage: thumbnailImage ?? .placeholder,
                                  contentModes: .init(success: .scaleAspectFit, failure: .scaleAspectFit, placeholder: .scaleAspectFit)) { [weak self] _ in
            guard let self else { return }
            if let averageColor = self.headerImageView.image?.averageColor {
                self.colorBackgroundView.backgroundColor = averageColor
            }
        }
    }

    func handleScrollViewDidScrolled(offsetY: CGFloat) {
        backgroundViewConstraints?.top?.constant = offsetY
    }
    
    override func setupViews() {
        super.setupViews()

        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1)
        ])

        [colorBackgroundView].forEach { contentView.addSubview($0) }

        let blurBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

        backgroundViewConstraints = colorBackgroundView.fillSuperview()

        [blurBackgroundView, gradientTransitionBackgroundView, headerImageView].forEach { colorBackgroundView.addSubview($0) }
        blurBackgroundView.fillSuperview()

        gradientTransitionBackgroundView.anchor(leading: colorBackgroundView.leadingAnchor,
                                                bottom: colorBackgroundView.bottomAnchor,
                                                trailing: colorBackgroundView.trailingAnchor,
                                                heightAnchor: contentView.heightAnchor)

        headerImageView.anchor(top: colorBackgroundView.topAnchor,
                               bottom: colorBackgroundView.bottomAnchor,
                               padding: .init(top: statusBarHeight, left: 0, bottom: 24, right: 0),
                               widthAnchor: colorBackgroundView.widthAnchor,
                               centerX: colorBackgroundView.centerXAnchor)

        gradientTransitionBackgroundView.layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = contentView.bounds
    }
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
