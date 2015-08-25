//
//  PlaylistRequest.swift
//  
//
//  Created by Kevin DELANNOY on 06/08/15.
//
//

import UIKit

public extension Playlist {
    internal static let BaseURL = NSURL(string: "https://api.soundcloud.com/playlists")!

    /**
    Load playlist with a specific identifier

    :param: identifier  The identifier of the playlist to load
    :param: secretToken The secret token to access the playlist or nil
    :param: completion  The closure that will be called when playlist is loaded or upon error
    */
    public static func playlist(identifier: Int, secretToken: String? = nil, completion: Result<Playlist> -> Void) {
        let URL = BaseURL.URLByAppendingPathComponent("\(identifier)")

        var parameters = ["client_id": Soundcloud.clientIdentifier!]
        if let secretToken = secretToken {
            parameters["secret_token"] = secretToken
        }

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            if let playlist = Playlist(JSON: $0) {
                return .Success(Box(playlist))
            }
            return .Failure(GenericError)
        }, completion: completion)
        request.start()
    }
}
