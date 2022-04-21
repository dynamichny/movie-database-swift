//
//  LabelWithTitle.swift
//  movies
//
//  Created by Marcin Pawlicki on 21/04/2022.
//

import UIKit

class LabelWithTitle: UIView {
   
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.numberOfLines = 1
        return label
    }()
    
    private let mainTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
       
    
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        addSubview(mainTextLabel)
        setupSubviews(rect: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override var frame: CGRect {
        willSet {
            setupSubviews(rect: newValue)
        }
      }
    
    func configure(title: String, mainText: String) {
        titleLabel.text = title
        mainTextLabel.text = mainText
    }
    
    
    private func setupSubviews(rect: CGRect) {
        titleLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: rect.width,
            height: 20
        )
        
        mainTextLabel.frame = CGRect(
            x: 0,
            y: titleLabel.bottom,
            width: rect.width,
            height: rect.height - 20
        )
    }
    
}
