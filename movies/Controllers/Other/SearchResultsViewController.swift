//
//  SearchResultsViewController.swift
//  movies
//
//  Created by Marcin Pawlicki on 23/04/2022.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapResult(_ result: Movie)
}

class SearchResultsViewController: UIViewController {
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private var results: [Movie] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Public
    
    func update(with movies: [Movie]) {
        results = movies
        tableView.reloadData()
        tableView.isHidden = movies.isEmpty
    }
    
}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath) as? SearchResultTableViewCell else {
            return UITableViewCell()
        }
        
        let movie = results[indexPath.row]
        cell.configure(
            with: SearchResultTableViewCellViewModel(
                title: movie.title,
                coverURL: URL(string: APICaller.Constants.imagesURL(size: .Small) + (movie.poster_path ?? "")))
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = results[indexPath.row]
        delegate?.didTapResult(result)
    }
}
