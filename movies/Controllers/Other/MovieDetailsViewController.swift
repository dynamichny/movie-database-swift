//
//  MovieDetailsViewController.swift
//  movies
//
//  Created by Marcin Pawlicki on 19/04/2022.
//

import UIKit
import SDWebImage

enum MovieDetailsSectionType {
    case genres(viewModels: [Genre])
    case companies(viewModels: [String])
    
    var title: String {
        switch self {
        case .companies:
            return "Companies responsible"
        case .genres:
            return "Connected genres"
        }
    }
}

class MovieDetailsViewController: UIViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let movieId: Int
    private var movieDetails: MovieDetails?
    
    private var isStared: Bool = false
    private var persistedItem: PersistedMovie?
    
    private let scrollView = UIScrollView()
    
    private let backdropImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemBackground
        imageView.clipsToBounds = true
        imageView.applyBlurEffect()
        return imageView
    }()
    
    private let posterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 1
        imageView.layer.shadowOffset = .zero
        imageView.layer.shadowRadius = 10
        
        return imageView
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let releaseDate = LabelWithTitle()
    
    private let rating = LabelWithTitle()
    
    private let runtime = LabelWithTitle()
    
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        ))
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(80)
            ),
            subitem: item,
            count: 2
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
        return section
    })
    
    private var sections = [MovieDetailsSectionType]()
    
    
    // MARK: - Lifecycle
    
    init(movieId: Int) {
        self.movieId = movieId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.backgroundColor = .systemBackground
        
        scrollView.addSubview(backdropImage)
        scrollView.addSubview(posterImage)
        scrollView.addSubview(taglineLabel)
        scrollView.addSubview(overviewLabel)
        scrollView.addSubview(releaseDate)
        scrollView.addSubview(rating)
        scrollView.addSubview(runtime)
        scrollView.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            GenreCollectionViewCell.self,
            forCellWithReuseIdentifier: GenreCollectionViewCell.identifier
        )
        collectionView.register(
            CompanyCollectionViewCell.self,
            forCellWithReuseIdentifier: CompanyCollectionViewCell.identifier
        )
        collectionView.register(
            SectionHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderCollectionReusableView.identifier
        )
        
        checkIfAddedToLibrary()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: isStared ? "star.fill" : "star"),
            style: .plain,
            target: self,
            action: #selector(toggleInLibrary)
        )
        
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        let posterHeight: CGFloat = view.width/2 * 1.25
        let posterOffset: CGFloat = 30
        
        let rightSideX = view.width/2 + 20
        
        backdropImage.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: posterHeight + posterOffset * 2
        )
        posterImage.frame = CGRect(
            x: 20,
            y: posterOffset,
            width: view.width / 2 - 20,
            height: posterHeight
        )
        rating.frame = CGRect(
            x: rightSideX,
            y: posterImage.top + 20,
            width: view.width - 20,
            height: 50
        )
        releaseDate.frame = CGRect(
            x: rightSideX,
            y: posterImage.bottom - 50 - 20,
            width: view.width - 20,
            height: 50
        )
        runtime.frame = CGRect(
            x: rightSideX,
            y: rating.bottom + (releaseDate.top - rating.bottom)/2 - 25,
            width: view.width - 20,
            height: 50
        )
        
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(
            width: view.width,
            height: view.frame.height
        )
    }
    
    // MARK: - Private
    
    private func fetchData() {
        APICaller.shared.getMovieDetailsFrom(id: movieId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.movieDetails = model
                    self?.sections = [
                        MovieDetailsSectionType.genres(viewModels: model.genres ?? []),
                        MovieDetailsSectionType.companies(viewModels: model.production_companies?.compactMap({ $0.logo_path }) ?? [])
                    ]
                    self?.configureViews()
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            }
        }
    }
    
    private func configureViews() {
        backdropImage.sd_setImage(with: URL(string: APICaller.Constants.imagesURL(size: .Backdrop) + (movieDetails?.backdrop_path ?? "")))
        posterImage.sd_setImage(with: URL(string: APICaller.Constants.imagesURL(size: .Big) + (movieDetails?.poster_path ?? "")))
        
        taglineLabel.text = movieDetails?.tagline ?? ""
        taglineLabel.frame = CGRect(
            x: 20,
            y: backdropImage.bottom + 10,
            width: view.width - 40,
            height: NSAttributedString.init(
                string: movieDetails?.tagline ?? "",
                attributes: [NSAttributedString.Key.font: taglineLabel.font!]
            ).boundingRect(with: CGSize(width: view.width - 40, height: 9999), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size.height
        )
        
        overviewLabel.text = movieDetails?.overview ?? ""
        overviewLabel.frame = CGRect(
            x: 20,
            y: taglineLabel.bottom + 10,
            width: view.width - 40,
            height: NSAttributedString.init(
                string: movieDetails?.overview ?? "",
                attributes: [NSAttributedString.Key.font: overviewLabel.font!]
            ).boundingRect(with: CGSize(width: view.width - 40, height: 9999), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size.height
        )
        
        if let release_date = movieDetails?.release_date  {
            releaseDate.configure(
                title: String.localized(key: "movie_details.release_date"),
                mainText: "\(String.formattedDate(string: release_date))"
            )
        }
        
        rating.configure(
            title: "\(String.localized(key: "movie_details.rating")) (\(movieDetails?.vote_count ?? 0) votes)",
            mainText: "\(Float(movieDetails?.vote_average ?? 0))/10"
        )
        runtime.configure(
            title: String.localized(key: "movie_details.runtime"),
            mainText: "\(movieDetails?.runtime ?? 0) min"
        )
        
        collectionView.frame = CGRect(x: 0, y: overviewLabel.bottom, width: view.width, height: 0)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: 0
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 0
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: 0
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: collectionView.bottomAnchor,
                constant: 40
            ),
        ])
        
    }
    
    private func checkIfAddedToLibrary() {
        do {
            let persistedMovies = try context.fetch(PersistedMovie.fetchRequest())
            persistedItem = persistedMovies.first(where: { $0.id == movieId })
            if persistedItem != nil {
                isStared = true
            }
        }
        catch {
            print("error while fetching movies")
        }
    }
    
    @objc private func toggleInLibrary() {
        isStared = !isStared
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: isStared ? "star.fill" : "star")
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if isStared {
            let newPersistedMovie = PersistedMovie(context: context)
            newPersistedMovie.title = movieDetails?.title ?? ""
            newPersistedMovie.poster_path = movieDetails?.poster_path ?? ""
            newPersistedMovie.release_date = movieDetails?.release_date ?? ""
            newPersistedMovie.backdrop_path = movieDetails?.backdrop_path ?? ""
            newPersistedMovie.id = Int64(movieId)
            
            persistedItem = newPersistedMovie
            
            do {
                try context.save()
            }
            catch {
                print("error while saving movie")
            }
        } else if persistedItem != nil {
            context.delete(persistedItem!)
        }
        
    }
}

extension MovieDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .companies(let viewModels):
            return viewModels.count
        case .genres(let viewModels):
            return viewModels.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.collectionView.sizeToFit()
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        
        switch type {
        case .genres(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GenreCollectionViewCell.identifier,
                for: indexPath
            ) as? GenreCollectionViewCell else {
                return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel.name)
            
            return cell
        case .companies(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CompanyCollectionViewCell.identifier,
                for: indexPath
            ) as? CompanyCollectionViewCell else {
                return UICollectionViewCell()
            }
            let imageSource = viewModels[indexPath.row]
            print(imageSource)
            cell.configure(with: URL(string: APICaller.Constants.imagesURL(size: .Medium) + imageSource)!)
            
            return cell
        }
    }
}
