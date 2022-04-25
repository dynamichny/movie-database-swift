//
//  HomeViewController.swift
//  movies
//
//  Created by Marcin Pawlicki on 14/04/2022.
//

import UIKit

class MoviesViewController: UIViewController {
    
    private var movieViewModels = [PosterMovieCollectionViewCellViewModel]()
    private var movies = [Movie]()
    private let genre: Genre
    
    private var page = 1
    private var isFetching = false
    
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
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
    )
    
    // MARK: - Init
    
    init(genre: Genre) {
        self.genre = genre
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title  = genre.name
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
        if isFetching {
           return
        }
        isFetching = true
        APICaller.shared.getMoviesBy(genreId: genre.id, page: page, compelition: { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.movies.append(contentsOf: model.results)
                    self?.movieViewModels.append(
                        contentsOf: model.results.compactMap({
                            return PosterMovieCollectionViewCellViewModel(
                                title: $0.title,
                                coverURL: URL(string: APICaller.Constants.imagesURL(size: .Medium) + ($0.poster_path ?? ""))
                            )
                        })
                    )
                    self?.collectionView.reloadData()
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
                self?.page += 1
                self?.isFetching = false
            }
        })
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.register(
            PosterMovieCollectionViewCell.self,
            forCellWithReuseIdentifier: PosterMovieCollectionViewCell.identifier
        )
        
        collectionView.register(
            SectionHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderCollectionReusableView.identifier
        )
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
    }
}


extension MoviesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PosterMovieCollectionViewCell.identifier,
            for: indexPath
        ) as? PosterMovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: movieViewModels[indexPath.row])
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let vc = MovieDetailsViewController(movieId: movie.id)
        vc.title = movie.title
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if movieViewModels.count - indexPath.row < 5 {
            fetchData()
        }
    }
}
