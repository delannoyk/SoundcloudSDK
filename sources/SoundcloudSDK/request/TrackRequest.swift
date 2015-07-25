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

    :param: identifier The identifier of the track to load
    :param: completion The closure that will be called when track is loaded or upon error
    */
    public static func track(identifier: Int, completion: Result<Track> -> Void) {
        let URL = BaseURL.URLByAppendingPathComponent("\(identifier).json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            if let track = Track(JSON: $0) {
                return .Success(Box(track))
            }
            return .Failure(GenericError)
        }, completion: completion)
        request.start()
    }

    /**
    Load tracks with specific identifiers

    :param: identifiers The identifiers of the tracks to load
    :param: completion  The closure that will be called when tracks are loaded or upon error
    */
    public static func tracks(identifiers: [Int], completion: Result<[Track]> -> Void) {
        let URL = BaseURL
        let parameters = [
            "client_id": Soundcloud.clientIdentifier!,
            "ids": ",".join(identifiers.map { "\($0)" })
        ]

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
    Load comments relative to a track

    :param: completion The closure that will be called when the comments are loaded or upon error
    */
    public func comments(completion: Result<[Comment]> -> Void) {
        let URL = Track.BaseURL.URLByAppendingPathComponent("\(identifier)/comments.json")
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
    Create a new comment on a track
    
    **This method requires a Session.**

    :param: body       The text body of the comment
    :param: timestamp  The progression of the track when the comment was validated
    :param: completion The closure that will be called when the comment is posted or upon error
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
                    return .Success(Box(comments))
                }
                return .Failure(GenericError)
            }, completion: completion)
            request.start()
        }
        else {
            completion(.Failure(GenericError))
        }
    }

    /**
    Fetch the list of users that favorited the track.

    :param: completion The closure that will be called when users are loaded or upon error
    */
    public func favoriters(completion: Result<[User]> -> Void) {
        let URL = Track.BaseURL.URLByAppendingPathComponent("\(identifier)/favoriters.json")
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
