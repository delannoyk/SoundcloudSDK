//
//  SearchQuery.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 18/10/15.
//  Copyright © 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public enum SearchQueryOptions {
    case queryString(String)
    case tags([String])
    case genres([String])
    case types([TrackType])
    case bpmFrom(Int)
    case bpmTo(Int)

    var query: (String, String) {
        switch self {
        case .queryString(let query):
            return ("q", query)
        case .tags(let tags):
            return ("tags", tags.joined(separator: ","))
        case .genres(let genres):
            return ("genres", genres.joined(separator: ","))
        case .types(let types):
            return ("types", types.map { $0.rawValue }.joined(separator: ","))
        case .bpmFrom(let from):
            return ("bpm[from]", String(from))
        case .bpmTo(let to):
            return ("bpm[to]", String(to))
        }
    }
}
