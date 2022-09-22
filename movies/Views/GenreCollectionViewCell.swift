//
//  GenreCollectionViewCell.swift
//  movies
//
//  Created by Marcin Pawlicki on 23/04/2022.
//

import UIKit

class GenreCollectionViewCell: UICollectionViewCell {
    static let identifier = "GenreCollectionViewCell"
    
    private let colors: [UIColor] = [
        .primaryGreen,
        .gray,
        .darkGray,
        .secondarySystemBackground,
        .lightGray,
        .primaryGreen
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .label
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = colors.randomElement()
        
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(
            x: 10,
            y: contentView.height - 30 - 10,
            width: contentView.width - 20,
            height: 30
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
}
