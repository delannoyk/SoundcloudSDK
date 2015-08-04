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
    internal init(identifier: Int, URL: NSURL?, permalinkURL: NSURL?, name: String) {
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
                URL: JSON["uri"].URLValue,
                permalinkURL: JSON["permalink_url"].URLValue,
                name: JSON["name"].stringValue ?? ""
            )
        }
        else {
            return nil
        }
    }
}

////////////////////////////////////////////////////////////////////////////


// MARK: Caching ease
////////////////////////////////////////////////////////////////////////////

public extension App {
    /**
    Returns NSData to ease caching of the struct.

    :returns: NSData representation of the struct.
    */
    public mutating func toData() -> NSData {
        return NSData(bytes: &self, length: sizeof(self.dynamicType))
    }

    internal static var empty: App {
        return App(identifier: 0, URL: nil, permalinkURL: nil, name: "")
    }

    /**
    Initialize a new struct from NSData.

    :param: data NSData representation of the struct.

    :returns: An initialized struct.
    */
    public static func fromData(data: NSData) -> App {
        var app = empty
        data.getBytes(&app, length: sizeof(App))
        return app
    }
}

////////////////////////////////////////////////////////////////////////////


// MARK: Equatable
////////////////////////////////////////////////////////////////////////////

extension App: Equatable {}

/**
Compares 2 Apps based on their identifier

:param: lhs First app
:param: rhs Second app

:returns: true if apps are equals, false if they're not
*/
public func ==(lhs: App, rhs: App) -> Bool {
    return lhs.identifier == rhs.identifier
}

////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
