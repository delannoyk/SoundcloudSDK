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

    - parameter identifier:  The identifier of the playlist to load
    - parameter secretToken: The secret token to access the playlist or nil
    - parameter completion:  The closure that will be called when playlist is loaded or upon error
    */
    public static func playlist(identifier: Int, secretToken: String? = nil, completion: SimpleAPIResponse<Playlist> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }

        let URL = BaseURL.URLByAppendingPathComponent("\(identifier)")

        var parameters = ["client_id": clientIdentifier]
        if let secretToken = secretToken {
            parameters["secret_token"] = secretToken
        }

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            if let playlist = Playlist(JSON: $0) {
                return .Success(playlist)
            }
            return .Failure(.Parsing)
            }, completion: { result in
                completion(SimpleAPIResponse(result))
        })
        request.start()
    }
}
