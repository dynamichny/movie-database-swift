//
//  GenresResponse.swift
//  movies
//
//  Created by Marcin Pawlicki on 23/04/2022.
//

import Foundation

struct GenresResponse: Codable {
    let genres: [Genre]
}

struct Genre: Codable {
    let id: Int
    let name: String
}
