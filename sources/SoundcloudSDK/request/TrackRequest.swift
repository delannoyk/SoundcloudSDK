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
        //GET	/tracks.json?{ids}	tracks
    }

    public func comments(completion: Void) {
        //GET	/tracks/{id}/comments.json	comments for the track

    }
}