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

    #if os(iOS) || os(OSX)
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

    public func addTrack(trackIdentifier: Int, completion: SimpleAPIResponse<Playlist> -> Void) {
        addTracks([trackIdentifier], completion: completion)
    }

    public func addTracks(trackIdentifiers: [Int], completion: SimpleAPIResponse<Playlist> -> Void) {
        updateTracksWithNewList(tracks.map { $0.identifier } + trackIdentifiers, completion: completion)
    }

    public func removeTrack(trackIdentifier: Int, completion: SimpleAPIResponse<Playlist> -> Void) {
        removeTracks([trackIdentifier], completion: completion)
    }

    public func removeTracks(trackIdentifiers: [Int], completion: SimpleAPIResponse<Playlist> -> Void) {
        updateTracksWithNewList(tracks
            .map { $0.identifier }
            .filter { !trackIdentifiers.contains($0) }, completion: completion)
    }

    private func updateTracksWithNewList(trackIdentifiers: [Int], completion: SimpleAPIResponse<Playlist> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }

        guard let oauthToken = Soundcloud.session?.accessToken else {
            completion(SimpleAPIResponse(.NeedsLogin))
            return
        }

        let queryStringParameters = ["client_id": clientIdentifier, "oauth_token": oauthToken]
        let URL = Playlist.BaseURL.URLByAppendingPathComponent("\(identifier)")
            .URLByAppendingQueryString(queryStringParameters.queryString)

        let parameters = [
            "playlist": [
                "tracks": trackIdentifiers.map { ["id": "\($0)"] }
            ]
        ]
        guard let JSONEncoded = try? NSJSONSerialization.dataWithJSONObject(parameters, options: []) else {
            completion(SimpleAPIResponse(.Parsing))
            return
        }

        let request = Request(URL: URL, method: .PUT, parameters: JSONEncoded, headers: ["Content-Type": "application/json"], parse: {
            if let playlist = Playlist(JSON: $0) {
                return .Success(playlist)
            }
            return .Failure(.Parsing)
        }) { result in
            completion(SimpleAPIResponse(result))
        }
        request.start()
    }
    #endif
}
