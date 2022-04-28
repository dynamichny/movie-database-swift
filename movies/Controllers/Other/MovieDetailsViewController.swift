//
//  MovieDetailsViewController.swift
//  movies
//
//  Created by Marcin Pawlicki on 19/04/2022.
//

import UIKit
import SDWebImage

class MovieDetailsViewController: UIViewController {
    
    private let movieId: Int
    private var movieDetails: MovieDetails?
    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "star"),
            style: .plain,
            target: self,
            action: #selector(addToLibrary)
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
        taglineLabel.frame = CGRect(
            x: 20,
            y: backdropImage.bottom + 10,
            width: view.width - 40,
            height: 60
        )
        overviewLabel.frame = CGRect(
            x: 20,
            y: taglineLabel.bottom,
            width: view.width - 40,
            height: 0
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
        
        overviewLabel.text = movieDetails?.overview ?? ""
        overviewLabel.sizeToFit()
        
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
        
    }
    
    @objc private func addToLibrary() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newPersistedMovie = PersistedMovie(context: context)
        newPersistedMovie.title = movieDetails?.title ?? ""
        newPersistedMovie.poster_path = movieDetails?.poster_path ?? ""
        newPersistedMovie.release_date = movieDetails?.release_date ?? ""
        newPersistedMovie.backdrop_path = movieDetails?.backdrop_path ?? ""
        newPersistedMovie.id = Int64(movieId)
        do {
            try context.save()
        }
        catch {
            print("error while saving movie")
        }
    }
}
