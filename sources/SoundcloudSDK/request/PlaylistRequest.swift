//
//  PlaylistRequest.swift
//  
//
//  Created by Kevin DELANNOY on 06/08/15.
//
//

import Foundation

public extension Playlist {
    static let BaseURL = URL(string: "https://api.soundcloud.com/playlists")!

    /**
    Load playlist with a specific identifier

    - parameter identifier:  The identifier of the playlist to load
    - parameter secretToken: The secret token to access the playlist or nil
    - parameter completion:  The closure that will be called when playlist is loaded or upon error
    */
    public static func playlist(identifier: Int, secretToken: String? = nil, completion: @escaping (SimpleAPIResponse<Playlist>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(error: .credentialsNotSet))
            return
        }

        let url = BaseURL.appendingPathComponent("\(identifier)")

        var parameters = ["client_id": clientIdentifier]
        if let secretToken = secretToken {
            parameters["secret_token"] = secretToken
        }

        let request = Request(url: url, method: .GET, parameters: parameters, parse: {
            if let playlist = Playlist(JSON: $0) {
                return .Success(playlist)
            }
            return .Failure(.parsing)
        }) { result in
            completion(SimpleAPIResponse(result: result))
        }
        request.start()
    }

    #if os(iOS) || os(OSX)
    /**
     Creates a playlist with a name and a specific sharing access

     - parameter name:          The name of the playlist
     - parameter sharingAccess: The required sharing access
     - parameter completion:    The closure that will be called when playlist is created or upon error
     */
    public static func create(name: String, sharingAccess: SharingAccess, completion: @escaping (SimpleAPIResponse<Playlist>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(error: .credentialsNotSet))
            return
        }

        guard let oauthToken = Soundcloud.session?.accessToken else {
            completion(SimpleAPIResponse(error: .needsLogin))
            return
        }

        let queryStringParameters = ["client_id": clientIdentifier, "oauth_token": oauthToken]
        let url = BaseURL.appendingQueryString(queryStringParameters.queryString)

        let parameters = [
            "playlist[title]": name,
            "playlist[sharing]": sharingAccess.rawValue]

        let request = Request(url: url, method: .POST, parameters: parameters, parse: {
            if let playlist = Playlist(JSON: $0) {
                return .Success(playlist)
            }
            return .Failure(.parsing)
        }) { result in
            completion(SimpleAPIResponse(result: result))
        }
        request.start()
    }

    public func addTrack(with identifier: Int, completion: @escaping (SimpleAPIResponse<Playlist>) -> Void) {
        addTracks(with: [identifier], completion: completion)
    }

    public func addTracks(with identifiers: [Int], completion: @escaping (SimpleAPIResponse<Playlist>) -> Void) {
        updateTracks(withNewTracklist: tracks.map { $0.identifier } + identifiers, completion: completion)
    }

    public func removeTrack(with identifier: Int, completion: @escaping (SimpleAPIResponse<Playlist>) -> Void) {
        removeTracks(with: [identifier], completion: completion)
    }

    public func removeTracks(with identifiers: [Int], completion: @escaping (SimpleAPIResponse<Playlist>) -> Void) {
        updateTracks(withNewTracklist: tracks
            .map { $0.identifier }
            .filter { !identifiers.contains($0) }, completion: completion)
    }

    private func updateTracks(withNewTracklist identifiers: [Int], completion: @escaping (SimpleAPIResponse<Playlist>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(error: .credentialsNotSet))
            return
        }

        guard let oauthToken = Soundcloud.session?.accessToken else {
            completion(SimpleAPIResponse(error: .needsLogin))
            return
        }

        let queryStringParameters = ["client_id": clientIdentifier, "oauth_token": oauthToken]
        let url = Playlist.BaseURL
            .appendingPathComponent("\(identifier)")
            .appendingQueryString(queryStringParameters.queryString)

        let parameters = [
            "playlist": [
                "tracks": identifiers.map { ["id": "\($0)"] }
            ]
        ]
        guard let JSONEncoded = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            completion(SimpleAPIResponse(error: .parsing))
            return
        }

        let request = Request(url: url, method: .PUT, parameters: JSONEncoded, headers: ["Content-Type": "application/json"], parse: {
            if let playlist = Playlist(JSON: $0) {
                return .Success(playlist)
            }
            return .Failure(.parsing)
        }) { result in
            completion(SimpleAPIResponse(result: result))
        }
        request.start()
    }
    #endif
}
