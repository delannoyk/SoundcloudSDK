//
//  SearchQuery.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 18/10/15.
//  Copyright © 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public enum SearchQueryOptions {
    case QueryString(String)
    case Tags([String])
    case Genres([String])
    case Types([TrackType])
    case BpmFrom(Int)
    case BpmTo(Int)

    internal var query: (String, String) {
        switch self {
        case .QueryString(let query):
            return ("q", query)
        case .Tags(let tags):
            return ("tags", tags.joinWithSeparator(","))
        case .Genres(let genres):
            return ("genres", genres.joinWithSeparator(","))
        case .Types(let types):
            return ("types", types.map { $0.rawValue }.joinWithSeparator(","))
        case .BpmFrom(let from):
            return ("bpm[from]", String(from))
        case .BpmTo(let to):
            return ("bpm[to]", String(to))
        }
    }
}
