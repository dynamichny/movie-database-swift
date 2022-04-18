//
//  Movie.swift
//  movies
//
//  Created by Marcin Pawlicki on 14/04/2022.
//

import Foundation

struct Movie: Codable {
    let poster_path: String?
    let adult: Bool
    let overview: String
    let release_date: String
    let genre_ids: [Int]
    let id: Int
    let original_title: String
    let original_language: String
    let title: String
    let backdrop_path: String?
    let popularity: Float
    let vote_count: Int
    let vote_average: Float
}
