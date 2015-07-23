//
//  UserRequest.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import UIKit

public extension User {
    private static let BaseURL = NSURL(string: "https://api.soundcloud.com/users")!

    internal static func user(identifier: Int, completion: Result<User> -> Void) {
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
}
