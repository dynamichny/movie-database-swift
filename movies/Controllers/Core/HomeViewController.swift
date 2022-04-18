//
//  HomeViewController.swift
//  movies
//
//  Created by Marcin Pawlicki on 14/04/2022.
//

import UIKit

class HomeViewController: UIViewController {
        
    private var popularMoviesViewModels = [PopularMoviesCollectionViewCellViewModel]()
    
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(300)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 8, trailing: 4)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(300)
                ),
                subitem: item,
                count: 2
            )
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            
            return NSCollectionLayoutSection(group: group)
        }
    )
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title  = "Home"
        view.backgroundColor = .systemBackground
        
        configureCollectionView()
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: - Private
    
    private func fetchData() {
        APICaller.shared.getPopularMovies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.popularMoviesViewModels = model.results.compactMap({
                        return PopularMoviesCollectionViewCellViewModel(
                            title: $0.title,
                            coverURL: URL(string: "https://image.tmdb.org/t/p/w500\($0.poster_path ?? "")")
                        )
                    })
                    self?.collectionView.reloadData()
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            }
        }
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.register(
            PopularMoviesCollectionViewCell.self,
            forCellWithReuseIdentifier: PopularMoviesCollectionViewCell.identifier
        )
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularMoviesViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PopularMoviesCollectionViewCell.identifier,
            for: indexPath
        ) as? PopularMoviesCollectionViewCell else {
            return UICollectionViewCell()
        }
            
        cell.configure(with: popularMoviesViewModels[indexPath.row])
        
        return cell
    }
}
