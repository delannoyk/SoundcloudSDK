//
//  ImageURLs.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 26/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public struct ImageURLs {
    private let baseURL: URL?

    public init(baseURL: URL?) {
        self.baseURL = baseURL
    }

    public var miniURL: URL? {
        return URLWithFormat("mini")
    }

    public var tinyURL: URL? {
        return URLWithFormat("tiny")
    }

    public var smallURL: URL? {
        return URLWithFormat("small")
    }

    public var badgeURL: URL? {
        return URLWithFormat("badge")
    }

    public var largeURL: URL? {
        return URLWithFormat("large")
    }

    public var cropURL: URL? {
        return URLWithFormat("crop")
    }

    public var highURL: URL? {
        return URLWithFormat("t500x500")
    }

    private func URLWithFormat(_ format: String) -> URL? {
        let urlString = baseURL?
            .absoluteString?
            .replacingOccurrences(of: "large", with: format)
        return URL(string: urlString ?? "")
    }
}
