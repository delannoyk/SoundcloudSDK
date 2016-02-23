//
//  ImageURLs.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 26/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public struct ImageURLs {
    private let baseURL: NSURL?

    public init(baseURL: NSURL?) {
        self.baseURL = baseURL
    }

    public var miniURL: NSURL? {
        return URLWithFormat("mini")
    }

    public var tinyURL: NSURL? {
        return URLWithFormat("tiny")
    }

    public var smallURL: NSURL? {
        return URLWithFormat("small")
    }

    public var badgeURL: NSURL? {
        return URLWithFormat("badge")
    }

    public var largeURL: NSURL? {
        return URLWithFormat("large")
    }

    public var cropURL: NSURL? {
        return URLWithFormat("crop")
    }

    public var highURL: NSURL? {
        return URLWithFormat("t500x500")
    }

    private func URLWithFormat(format: String) -> NSURL? {
        let urlString = baseURL?
            .absoluteString
            .stringByReplacingOccurrencesOfString("large", withString: format)
        return NSURL(string: urlString ?? "")
    }
}
