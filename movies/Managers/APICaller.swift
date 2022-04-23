//
//  APICaller.swift
//  movies
//
//  Created by Marcin Pawlicki on 14/04/2022.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    enum ImagesSizes: String {
        case Backdrop = "w780"
        case Big = "w342"
        case Medium = "w185"
        case Small = "w92"
    }
    
    struct Constants {
        static let baseURL = "https://api.themoviedb.org/3"
        static let apiKey = "485dd1f1ee71083619712efed20ee4bb"
        static func imagesURL(size: ImagesSizes?) -> String {
            if size != nil {
                return "https://image.tmdb.org/t/p/\(size!.rawValue)"
            }
            return "https://image.tmdb.org/t/p/original"
        }
        static let queries = "region=\(Locale.current.regionCode?.uppercased() ?? "EN")&language=\(Locale.current.identifier)&api_key=\(Constants.apiKey)"
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    // MARK:  - Popular movies
    
    func getPopularMovies(page: Int, completion: @escaping (Result<CommonMoviesResponse, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + "/movie/popular?page=\(page)&\(Constants.queries)"),
            type: .GET) { request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                    }
                    
                    do {
                        let response = try JSONDecoder().decode(CommonMoviesResponse.self, from: data)
                        completion(.success(response))
                    }
                    catch {
                        completion(.failure(error))
                    }
                }
                task.resume()
            }
    }
    
    // MARK: - Movie details
    
    func getMovieDetailsFrom(id movieId: Int, compelition: @escaping (Result<MovieDetails, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + "/movie/\(movieId)?\(Constants.queries)"),
            type: .GET) { request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        compelition(.failure(APIError.failedToGetData))
                        return
                    }
                    do {
                        let response = try JSONDecoder().decode(MovieDetails.self, from: data)
                        compelition(.success(response))
                    }
                    catch {
                        compelition(.failure(error))
                    }
                }
                task.resume()
            }
    }
    
    // MARK: - Search
    
    func getMoviesBy(query: String, compelition: @escaping (Result<CommonMoviesResponse, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + "/search/movie?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&\(Constants.queries)"),
            type: .GET) { request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        compelition(.failure(APIError.failedToGetData))
                        return
                    }
                    
                    do {
                        let result = try JSONDecoder().decode(CommonMoviesResponse.self, from: data)
                        compelition(.success(result))
                    }
                    catch {
                        compelition(.failure(error))
                    }
                }
                task.resume()
            }
    }
    
    func getMoviesBy(genreId: Int, page: Int, compelition: @escaping (Result<CommonMoviesResponse, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + "/discover/movie?with_genres=\(genreId)&page=\(page)&\(Constants.queries)"),
            type: .GET) { request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        compelition(.failure(APIError.failedToGetData))
                        return
                    }
                    
                    do {
                        let result = try JSONDecoder().decode(CommonMoviesResponse.self, from: data)
                        compelition(.success(result))
                    }
                    catch {
                        compelition(.failure(error))
                    }
                }
                task.resume()
            }
    }
    
    // MARK: - Genres
    
    func getGenres(compelition: @escaping (Result<GenresResponse, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + "/genre/movie/list?\(Constants.queries)"),
            type: .GET) { request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        compelition(.failure(APIError.failedToGetData))
                        return
                    }
                    
                    do {
                        let result = try JSONDecoder().decode(GenresResponse.self, from: data)
                        compelition(.success(result))
                    }
                    catch {
                        compelition(.failure(error))
                    }
                }
                task.resume()
            }
    }
    
    
    // MARK: - Private
    
    enum HTTPMethod: String {
        case GET
    }
    
    private func createRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void
    ) {
        guard let apiURL = url else {
            return
        }
        var request = URLRequest(url: apiURL)
        request.httpMethod = type.rawValue
        completion(request)
    }
    
}
