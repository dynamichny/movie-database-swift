//
//  MovieDetails.swift
//  movies
//
//  Created by Marcin Pawlicki on 21/04/2022.
//

import Foundation

struct MovieDetails: Codable {
    let adult: Bool?
    let backdrop_path: String?
    let budget: Int?
    let genres: [Genre]?
    let id: Int?
    let original_title: String?
    let overview: String?
    let poster_path: String?
    let production_companies: [ProductionCompanies]?
    let production_countries: [ProductionCountries]?
    let release_date: String?
    let runtime: Int?
    let status: ReleaseStatus?
    let tagline: String?
    let title: String?
    let vote_average: Float?
    let vote_count: Int?
}

struct Genre: Codable {
    let id: Int
    let name: String
}

struct ProductionCompanies: Codable {
    let logo_path: String?
    let name: String
}

struct ProductionCountries: Codable {
    let iso_3166_1: String
    let name: String
}

enum ReleaseStatus: String, Codable {
    case Rumored
    case Planned
    case InProduction = "In Production"
    case PostProduction = "Post Production"
    case Released
    case Canceled
}
