//
//  LibraryViewController.swift
//  movies
//
//  Created by Marcin Pawlicki on 14/04/2022.
//

import UIKit

struct LibraryTableSection {
    let title: String
    let results: [PersistedMovie]
}

class LibraryViewController: UIViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var sections = [LibraryTableSection]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LibraryMovieTableViewCell.self, forCellReuseIdentifier: LibraryMovieTableViewCell.identifier)
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.isHidden = true
        label.text = String.localized(key: "library.empty")
        label.textAlignment = .center
        
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.addSubview(emptyLabel)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        emptyLabel.frame = tableView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPersistedMovies()
    }
    
    
    // MARK: - Private
    
    private func fetchPersistedMovies() {
        do {
            let persistedMovies = try context.fetch(PersistedMovie.fetchRequest())
            updateTable(with: persistedMovies)
        }
        catch {
            print("error while fetching movies")
        }
    }
    
    private func updateTable(with results: [PersistedMovie]) {
        let today = Date()
        var released: [PersistedMovie] = []
        var unreleased: [PersistedMovie] = []
        
        emptyLabel.isHidden = !results.isEmpty
    
        for result in results {
            if let dateString = result.release_date,
               let releaseDate = DateFormatter.dateFormatter.date(from: dateString),
               releaseDate > today {
                unreleased.append(result)
                continue
            }
            released.append(result)
        }
        
        sections = []
        
        if unreleased.count > 0 {
            sections.append(LibraryTableSection(title: String.localized(key: "library.unreleased"), results: unreleased))
        }
        
        if released.count > 0 {
            sections.append(LibraryTableSection(title: String.localized(key: "library.released"), results: released))
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LibraryMovieTableViewCell.identifier,
            for: indexPath) as? LibraryMovieTableViewCell else {
            return UITableViewCell()
        }
        
        let movie = sections[indexPath.section].results[indexPath.row]
        cell.configure(
            with: LibraryMovieTableViewCellViewModel(
                title: movie.title ?? "",
                coverURL: URL(string: APICaller.Constants.imagesURL(size: .Medium) + (movie.poster_path ?? "")),
                release_date: movie.release_date ?? ""
            )
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        let vc = MovieDetailsViewController(movieId: Int(result.id))
        vc.title = result.title
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let movieToRemove = sections[indexPath.section].results[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: String.localized(key: "library.remove")) { (action, view, handler) in
            self.context.delete(movieToRemove)
            try! self.context.save()
            self.fetchPersistedMovies()
        }
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
}
