//
//  App.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

// MARK: - App definition
////////////////////////////////////////////////////////////////////////////

public struct App {
    public init(identifier: Int, URL: NSURL?, permalinkURL: NSURL?, name: String) {
        self.identifier = identifier
        self.URL = URL
        self.permalinkURL = permalinkURL
        self.name = name
    }

    ///App Identifier
    public let identifier: Int

    ///URL to the app (api)
    internal let URL: NSURL?

    ///URL to the app (website)
    public let permalinkURL: NSURL?

    ///Name of the app
    public let name: String
}

////////////////////////////////////////////////////////////////////////////


// MARK: - App Extensions
////////////////////////////////////////////////////////////////////////////

// MARK: Parsing
////////////////////////////////////////////////////////////////////////////

internal extension App {
    init?(JSON: JSONObject) {
        if let identifier = JSON["id"].intValue {
            self.init(
                identifier: identifier,
                URL: JSON["uri"].urlValue,
                permalinkURL: JSON["permalink_url"].urlValue,
                name: JSON["name"].stringValue ?? ""
            )
        }
        else {
            return nil
        }
    }
}

////////////////////////////////////////////////////////////////////////////


// MARK: Equatable
////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
