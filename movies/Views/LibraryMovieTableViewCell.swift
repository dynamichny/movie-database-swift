//
//  LibraryMovieTableViewCell.swift
//  movies
//
//  Created by Marcin Pawlicki on 25/04/2022.
//

import UIKit
import SDWebImage

class LibraryMovieTableViewCell: UITableViewCell {
    static let identifier = "LibraryMovieTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15, weight: .regular)
        
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
        contentView.addSubview(releaseDateLabel)
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
            width: 40,
            height: contentView.height - 10
        )
        titleLabel.frame = CGRect(
            x: posterImageView.width + 20,
            y: 5,
            width: contentView.width - posterImageView.width - 10 - 20,
            height: contentView.height / 2 - 5
        )
        releaseDateLabel.frame = CGRect(
            x: posterImageView.width + 20,
            y: titleLabel.bottom - 5,
            width: contentView.width - posterImageView.width - 10 - 20,
            height: contentView.height / 2 - 10
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        releaseDateLabel.text = nil
        posterImageView.image = nil
    }
    
    // MARK: - Public
    
    func configure(with viewModel: LibraryMovieTableViewCellViewModel) {
        titleLabel.text = viewModel.title
        releaseDateLabel.text = String.formattedDate(string: viewModel.release_date)
        posterImageView.sd_setImage(with: viewModel.coverURL)
    }
    
}
