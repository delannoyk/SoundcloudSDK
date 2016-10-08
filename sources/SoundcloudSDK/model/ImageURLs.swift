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
        return url(format: "mini")
    }

    public var tinyURL: URL? {
        return url(format: "tiny")
    }

    public var smallURL: URL? {
        return url(format: "small")
    }

    public var badgeURL: URL? {
        return url(format: "badge")
    }

    public var largeURL: URL? {
        return url(format: "large")
    }

    public var cropURL: URL? {
        return url(format: "crop")
    }

    public var highURL: URL? {
        return url(format: "t500x500")
    }

    private func url(format: String) -> URL? {
        let urlString = baseURL?
            .absoluteString
            .replacingOccurrences(of: "large", with: format)
        return URL(string: urlString ?? "")
    }
}
