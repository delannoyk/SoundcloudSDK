//
//  UserRequest.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import UIKit

public extension User {
    internal static let BaseURL = NSURL(string: "https://api.soundcloud.com/users")!

    /**
    Loads an user profile

    :param: identifier The identifier of the user to load
    :param: completion The closure that will be called when user profile is loaded or upon error
    */
    public static func user(identifier: Int, completion: Result<User> -> Void) {
        let URL = User.BaseURL.URLByAppendingPathComponent("\(identifier).json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            if let user = User(JSON: $0) {
                return .Success(Box(user))
            }
            return .Failure(GenericError)
        }, completion: completion)
        request.start()
    }

    /**
    Loads tracks the user uploaded to Soundcloud

    :param: completion The closure that will be called when tracks are loaded or upon error
    */
    public func tracks(completion: Result<[Track]> -> Void) {
        let URL = User.BaseURL.URLByAppendingPathComponent("\(identifier)/tracks.json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            let tracks = $0.map { return Track(JSON: $0) }
            if let tracks = tracks {
                return .Success(Box(compact(tracks)))
            }
            return .Failure(GenericError)
        }, completion: completion)
        request.start()
    }

    /**
    Load all comments from the user

    :param: completion The closure that will be called when the comments are loaded or upon error
    */
    public func comments(completion: Result<[Comment]> -> Void) {
        let URL = User.BaseURL.URLByAppendingPathComponent("\(identifier)/comments.json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            let comments = $0.map { return Comment(JSON: $0) }
            if let comments = comments {
                return .Success(Box(compact(comments)))
            }
            return .Failure(GenericError)
            }, completion: completion)
        request.start()
    }

    /**
    Loads favorited tracks of the user

    :param: completion The closure that will be called when tracks are loaded or upon error
    */
    public func favorites(completion: Result<[Track]> -> Void) {
        let URL = User.BaseURL.URLByAppendingPathComponent("\(identifier)/favorites.json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            let tracks = $0.map { return Track(JSON: $0) }
            if let tracks = tracks {
                return .Success(Box(compact(tracks)))
            }
            return .Failure(GenericError)
            }, completion: completion)
        request.start()
    }

    /**
    Loads followers of the user

    :param: completion The closure that will be called when followers are loaded or upon error
    */
    public func followers(completion: Result<[User]> -> Void) {
        let URL = User.BaseURL.URLByAppendingPathComponent("\(identifier)/followers.json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            let users = $0.map { return User(JSON: $0) }
            if let users = users {
                return .Success(Box(compact(users)))
            }
            return .Failure(GenericError)
            }, completion: completion)
        request.start()
    }

}
