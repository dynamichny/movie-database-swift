//
//  SectionHeaderCollectionReusableView.swift
//  movies
//
//  Created by Marcin Pawlicki on 19/04/2022.
//

import UIKit

class SectionHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "SectionHeaderCollectionReusableView"
    
    let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .light)
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 14, y: 0, width: width - 28, height: height)
    }
    
    func configure(with title: String) {
        label.text = title
    }
}
