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

    - parameter identifier: The identifier of the user to load
    - parameter completion: The closure that will be called when user profile is loaded or upon error
    */
    public static func user(identifier: Int, completion: Result<User> -> Void) {
        let URL = User.BaseURL.URLByAppendingPathComponent("\(identifier).json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            if let user = User(JSON: $0) {
                return .Success(user)
            }
            return .Failure(GenericError)
            }, completion: { result, response in
                completion(result)
        })
        request.start()
    }

    /**
    Loads tracks the user uploaded to Soundcloud

    - parameter completion: The closure that will be called when tracks are loaded or upon error
    */
    public func tracks(completion: Result<[Track]> -> Void) {
        let URL = User.BaseURL.URLByAppendingPathComponent("\(identifier)/tracks.json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            let tracks = $0.flatMap { return Track(JSON: $0) }
            if let tracks = tracks {
                return .Success(tracks)
            }
            return .Failure(GenericError)
            }, completion: { result, response in
                completion(result)
        })
        request.start()
    }

    /**
    Load all comments from the user

    - parameter completion: The closure that will be called when the comments are loaded or upon error
    */
    public func comments(completion: Result<[Comment]> -> Void) {
        let URL = User.BaseURL.URLByAppendingPathComponent("\(identifier)/comments.json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            let comments = $0.flatMap { return Comment(JSON: $0) }
            if let comments = comments {
                return .Success(comments)
            }
            return .Failure(GenericError)
            }, completion: { result, response in
                completion(result)
        })
        request.start()
    }

    /**
    Loads favorited tracks of the user

    - parameter completion: The closure that will be called when tracks are loaded or upon error
    */
    public func favorites(completion: Result<[Track]> -> Void) {
        let URL = User.BaseURL.URLByAppendingPathComponent("\(identifier)/favorites.json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            let tracks = $0.flatMap { return Track(JSON: $0) }
            if let tracks = tracks {
                return .Success(tracks)
            }
            return .Failure(GenericError)
            }, completion: { result, response in
                completion(result)
        })
        request.start()
    }

    /**
    Loads followers of the user

    - parameter completion: The closure that will be called when followers are loaded or upon error
    */
    public func followers(completion: Result<[User]> -> Void) {
        let URL = User.BaseURL.URLByAppendingPathComponent("\(identifier)/followers.json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            let users = $0.flatMap { return User(JSON: $0) }
            if let users = users {
                return .Success(users)
            }
            return .Failure(GenericError)
            }, completion: { result, response in
                completion(result)
        })
        request.start()
    }

    /**
    Loads followed users of the user

    - parameter completion: The closure that will be called when followed users are loaded or upon error
    */
    public func followings(completion: Result<[User]> -> Void) {
        let URL = User.BaseURL.URLByAppendingPathComponent("\(identifier)/followings.json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            let users = $0.flatMap { return User(JSON: $0) }
            if let users = users {
                return .Success(users)
            }
            return .Failure(GenericError)
            }, completion: { result, response in
                completion(result)
        })
        request.start()
    }

    /**
    Follow the given user.

    **This method requires a Session.**

    - parameter userIdentifier: The identifier of the user to follow
    - parameter completion:     The closure that will be called when the user has been followed or upon error
    */
    public func follow(userIdentifier: Int, completion: Result<Bool> -> Void) {
        changeFollowStatus(true, userIdentifier: userIdentifier, completion: completion)
    }

    /**
    Follow the given user.

    **This method requires a Session.**

    - parameter userIdentifier: The identifier of the user to unfollow
    - parameter completion:     The closure that will be called when the user has been unfollowed or upon error
    */
    public func unfollow(userIdentifier: Int, completion: Result<Bool> -> Void) {
        changeFollowStatus(false, userIdentifier: userIdentifier, completion: completion)
    }

    internal func changeFollowStatus(follow: Bool, userIdentifier: Int, completion: Result<Bool> -> Void) {
        if let oauthToken = Soundcloud.session?.accessToken {
            let baseURL = User.BaseURL.URLByAppendingPathComponent("\(identifier)/followings/\(userIdentifier).json")
            let parameters = ["client_id": Soundcloud.clientIdentifier!,
                "oauth_token": oauthToken
            ]

            let URL = baseURL.URLByAppendingQueryString(parameters.queryString)

            let request = Request(URL: URL, method: follow ? .PUT : .DELETE, parameters: nil, parse: {
                if let _ = User(JSON: $0) {
                    return .Success(true)
                }
                if let _ = $0["status"].stringValue?.rangeOfString(" OK") {
                    return .Success(true)
                }
                return .Failure(GenericError)
                }, completion: { result, response in
                    refreshTokenIfNecessaryCompletion(response, retry: {
                        self.changeFollowStatus(follow, userIdentifier: userIdentifier, completion: completion)
                        }, completion: completion, result: result)
            })
            request.start()
        }
        else {
            completion(.Failure(GenericError))
        }
    }

    /**
    Loads user's playlists

    - parameter completion: The closure that will be called when playlists has been loaded or upon error
    */
    public func playlists(completion: Result<[Playlist]> -> Void) {
        let URL = User.BaseURL.URLByAppendingPathComponent("\(identifier)/playlists.json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            let playlists = $0.flatMap { return Playlist(JSON: $0) }
            if let playlists = playlists {
                return .Success(playlists)
            }
            return .Failure(GenericError)
            }, completion: { result, response in
                completion(result)
        })
        request.start()
    }
}
