//
//  CompanyCollectionViewCell.swift
//  movies
//
//  Created by Marcin Pawlicki on 29/04/2022.
//

import UIKit
import SDWebImage

class CompanyCollectionViewCell: UICollectionViewCell {
    static let identifier = "CompanyCollectionViewCell"
    
    private let companyIconImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        addSubview(companyIconImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        companyIconImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: contentView.width,
            height: contentView.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        companyIconImageView.image = nil
    }
    
    // MARK: - Methods
    
    func configure(with imageURL: URL) {
        companyIconImageView.sd_setImage(with: imageURL)
    }
}
