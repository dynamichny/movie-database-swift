//
//  PopularMoviesResponse.swift
//  movies
//
//  Created by Marcin Pawlicki on 14/04/2022.
//

import Foundation

struct PopularMoviesResponse: Codable {
    let results: [Movie]
}
