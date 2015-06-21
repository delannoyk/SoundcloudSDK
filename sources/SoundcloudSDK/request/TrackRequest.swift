//
//  TrackRequest.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import UIKit

public extension Track {
    private static let BaseURL = NSURL(string: "https://api.soundcloud.com/tracks")!

    internal static func track(identifier: Int, completion: Result<Track> -> Void) {
        let URL = BaseURL.URLByAppendingPathComponent("\(identifier).json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            if let track = Track(JSON: $0) {
                return .Success(Box(track))
            }
            return .Failure(ParsingError)
        }, completion: completion)
        request.start()
    }

    internal static func tracks(identifiers: [Int], completion: Result<[Track]> -> Void) {
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
            return .Failure(ParsingError)
        }, completion: completion)
        request.start()
    }

    public func comments(completion: Result<[Comment]> -> Void) {
        let URL = Track.BaseURL.URLByAppendingPathComponent("\(identifier)/comments.json")
        let parameters = ["client_id": Soundcloud.clientIdentifier!]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            let comments = $0.map { return Comment(JSON: $0) }
            if let comments = comments {
                return .Success(Box(compact(comments)))
            }
            return .Failure(ParsingError)
        }, completion: completion)
        request.start()
    }
}
