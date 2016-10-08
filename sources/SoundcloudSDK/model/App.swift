//
//  App.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public struct App {
    ///App Identifier
    public let identifier: Int

    ///URL to the app (website)
    public let permalinkURL: URL?

    ///Name of the app
    public let name: String
}

// MARK: Parsing

extension App {
    init?(JSON: JSONObject) {
        guard let identifier = JSON["id"].intValue else {
            return nil
        }

        self.identifier = identifier
        self.permalinkURL = JSON["permalink_url"].urlValue
        self.name = JSON["name"].stringValue ?? ""
    }
}

// MARK: Equatable

extension App: Equatable {}

/**
Compares 2 Apps based on their identifier

- parameter lhs: First app
- parameter rhs: Second app

- returns: true if apps are equals, false if they're not
*/
public func ==(lhs: App, rhs: App) -> Bool {
    return lhs.identifier == rhs.identifier
}
