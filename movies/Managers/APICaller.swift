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
    
    struct Constants {
        static let baseURL = "https://api.themoviedb.org/3"
        static let apiKey = "485dd1f1ee71083619712efed20ee4bb"
        static let imagesURL = "https://image.tmdb.org/t/p/w500"
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    // MARK:  - Popular movies
    
    func getPopularMovies(completion: @escaping (Result<PopularMoviesResponse, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + "/movie/popular?api_key=\(Constants.apiKey)"),
            type: .GET) { request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                    }
                    
                    do {
                        let response = try JSONDecoder().decode(PopularMoviesResponse.self, from: data)
                        completion(.success(response))
                    }
                    catch {
                        completion(.failure(error))
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
