//
//  TrackRequest.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import UIKit

public extension Track {
    internal static let BaseURL = NSURL(string: "https://api.soundcloud.com/tracks")!

    /**
    Load track with a specific identifier

    - parameter identifier: The identifier of the track to load
    - parameter completion: The closure that will be called when track is loaded or upon error
    */
    public static func track(identifier: Int, completion: Result<Track> -> Void) {
        let URL = BaseURL.URLByAppendingPathComponent("\(identifier).json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            if let track = Track(JSON: $0) {
                return .Success(track)
            }
            return .Failure(GenericError)
            }, completion: { result, response in
                completion(result)
        })
        request.start()
    }

    /**
    Load tracks with specific identifiers

    - parameter identifiers: The identifiers of the tracks to load
    - parameter completion:  The closure that will be called when tracks are loaded or upon error
    */
    public static func tracks(identifiers: [Int], completion: Result<[Track]> -> Void) {
        let URL = BaseURL
        let parameters = [
            "client_id": Soundcloud.clientIdentifier!,
            "ids": identifiers.map { "\($0)" }.joinWithSeparator(",")
        ]

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
    Load comments relative to a track

    - parameter completion: The closure that will be called when the comments are loaded or upon error
    */
    public func comments(completion: Result<[Comment]> -> Void) {
        let URL = Track.BaseURL.URLByAppendingPathComponent("\(identifier)/comments.json")
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
    Create a new comment on a track
    
    **This method requires a Session.**

    - parameter body:       The text body of the comment
    - parameter timestamp:  The progression of the track when the comment was validated
    - parameter completion: The closure that will be called when the comment is posted or upon error
    */
    public func comment(body: String, timestamp: NSTimeInterval, completion: Result<Comment> -> Void) {
        if let oauthToken = Soundcloud.session?.accessToken {
            let URL = Track.BaseURL.URLByAppendingPathComponent("\(identifier)/comments.json")
            let parameters = ["client_id": Soundcloud.clientIdentifier!,
                "comment[body]": body,
                "comment[timestamp]": "\(timestamp)",
                "oauth_token": oauthToken
            ]

            let request = Request(URL: URL, method: .POST, parameters: parameters, parse: {
                if let comments = Comment(JSON: $0) {
                    return .Success(comments)
                }
                return .Failure(GenericError)
            }, completion: { result, response in
                refreshTokenIfNecessaryCompletion(response, retry: {
                    self.comment(body, timestamp: timestamp, completion: completion)
                    }, completion: completion, result: result)
            })
            request.start()
        }
        else {
            completion(.Failure(GenericError))
        }
    }

    /**
    Fetch the list of users that favorited the track.

    - parameter completion: The closure that will be called when users are loaded or upon error
    */
    public func favoriters(completion: Result<[User]> -> Void) {
        let URL = Track.BaseURL.URLByAppendingPathComponent("\(identifier)/favoriters.json")
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
    Favorites a track for the logged user
    
    **This method requires a Session.**

    - parameter userIdentifier: The identifier of the logged user
    - parameter completion:     The closure that will be called when the track has been favorited or upon error
    */
    public func favorite(userIdentifier: Int, completion: Result<Bool> -> Void) {
        if let oauthToken = Soundcloud.session?.accessToken {
            let baseURL = User.BaseURL.URLByAppendingPathComponent("\(userIdentifier)/favorites/\(identifier).json")
            let parameters = [
                "client_id": Soundcloud.clientIdentifier!,
                "oauth_token": oauthToken
            ]

            let URL = baseURL.URLByAppendingQueryString(parameters.queryString)
            let request = Request(URL: URL, method: .PUT, parameters: nil, parse: {
                if let _ = $0["status"].stringValue?.rangeOfString(" OK") {
                    return .Success(true)
                }
                if let _ = $0["status"].stringValue?.rangeOfString(" Created") {
                    return .Success(true)
                }
                return .Failure(GenericError)
                }, completion: { result, response in
                    refreshTokenIfNecessaryCompletion(response, retry: {
                        self.favorite(userIdentifier, completion: completion)
                        }, completion: completion, result: result)
            })
            request.start()
        }
        else {
            completion(.Failure(GenericError))
        }
    }
}
