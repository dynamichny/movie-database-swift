//
//  SearchResultTableViewCell.swift
//  movies
//
//  Created by Marcin Pawlicki on 23/04/2022.
//

import UIKit
import SDWebImage

class SearchResultTableViewCell: UITableViewCell {
    static let identifier = "SearchResultTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .regular)
        
        return label
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(posterImageView)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        posterImageView.frame = CGRect(
            x: 10,
            y: 5,
            width: 30,
            height: 50
        )
        titleLabel.frame = CGRect(
            x: posterImageView.width + 20,
            y: 5,
            width: contentView.width - posterImageView.width - 10 - 20,
            height: contentView.height - 10
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        posterImageView.image = nil
    }
    
    // MARK: - Public
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        posterImageView.sd_setImage(with: URL(string: APICaller.Constants.imagesURL(size: .Small) + (movie.poster_path ?? "")))
    }
    
}
