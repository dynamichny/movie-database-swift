//
//  PopularMoviesCollectionViewCell.swift
//  movies
//
//  Created by Marcin Pawlicki on 15/04/2022.
//

import UIKit
import SDWebImage

class PosterMovieCollectionViewCell: UICollectionViewCell {
    static let identifier = "PopularMoviesCollectionViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(posterImageView)
        contentView.clipsToBounds = true
        
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.sizeToFit()
        posterImageView.sizeToFit()
        
        posterImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: contentView.frame.width,
            height: contentView.frame.height - 100
        )
        
        nameLabel.frame = CGRect(
            x: 0,
            y: posterImageView.bottom + 10,
            width: contentView.width,
            height: contentView.height - posterImageView.bottom
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        posterImageView.image = nil
    }
    
    func configure(with viewModel: PosterMovieCollectionViewCellViewModel) {
        nameLabel.text = viewModel.title
        posterImageView.sd_setImage(with: viewModel.coverURL, completed: nil)
    }
    
}
