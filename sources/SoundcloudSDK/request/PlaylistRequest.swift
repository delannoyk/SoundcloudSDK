//
//  PlaylistRequest.swift
//  
//
//  Created by Kevin DELANNOY on 06/08/15.
//
//

import Foundation

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

    /**
     Creates a playlist with a name and a specific sharing access

     - parameter name:          The name of the playlist
     - parameter sharingAccess: The required sharing access
     - parameter completion:    The closure that will be called when playlist is created or upon error
     */
    public static func createWithName(name: String, sharingAccess: SharingAccess, completion: SimpleAPIResponse<Playlist> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }

        guard let oauthToken = Soundcloud.session?.accessToken else {
            completion(SimpleAPIResponse(.NeedsLogin))
            return
        }

        let queryStringParameters = ["client_id": clientIdentifier, "oauth_token": oauthToken]
        let URL = BaseURL.URLByAppendingQueryString(queryStringParameters.queryString)

        let parameters = ["playlist[title]": name,
            "playlist[sharing]": sharingAccess.rawValue]

        let request = Request(URL: URL, method: .POST, parameters: parameters, parse: {
            if let playlist = Playlist(JSON: $0) {
                return .Success(playlist)
            }
            return .Failure(.Parsing)
        }) { result in
            completion(SimpleAPIResponse(result))
        }
        request.start()
    }
}
