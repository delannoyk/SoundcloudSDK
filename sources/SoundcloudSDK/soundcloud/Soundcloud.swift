//
//  Soundcloud.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import UIKit

public class Soundcloud: NSObject {
    // MARK: Singleton
    ////////////////////////////////////////////////////////////////////////////

    internal static var instance = Soundcloud()

    private override init() {
        super.init()
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Properties
    ////////////////////////////////////////////////////////////////////////////

    internal var clientIdentifier: String?

    public static var clientIdentifier: String? {
        get {
            return instance.clientIdentifier
        }
        set {
            instance.clientIdentifier = newValue
        }
    }


    internal var clientSecret: String?

    public static var clientSecret: String? {
        get {
            return instance.clientSecret
        }
        set {
            instance.clientSecret = newValue
        }
    }


    internal var redirectURL: NSURL?

    public static var redirectURL: NSURL? {
        get {
            return instance.redirectURL
        }
        set {
            instance.redirectURL = newValue
        }
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: /user calls
    ////////////////////////////////////////////////////////////////////////////

    public static func user(identifier: Int, completion: Result<User> -> Void) {
        User.user(identifier, completion: completion)
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: - /tracks calls
    ////////////////////////////////////////////////////////////////////////////

    public static func track(identifier: Int, completion: Result<Track> -> Void) {
        Track.track(identifier, completion: completion)
    }

    public static func tracks(identifiers: [Int], completion: Result<[Track]> -> Void) {
        Track.tracks(identifiers, completion: completion)
    }

    ////////////////////////////////////////////////////////////////////////////
}
