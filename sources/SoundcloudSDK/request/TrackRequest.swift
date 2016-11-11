//
//  TrackRequest.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public extension Track {
    static let BaseURL = URL(string: "https://api.soundcloud.com/tracks")!

    /**
     Load track with a specific identifier

     - parameter identifier: The identifier of the track to load
     - parameter completion: The closure that will be called when track is loaded or upon error
     */
    public static func track(identifier: Int, completion: @escaping (SimpleAPIResponse<Track>) -> Void) {
        guard let clientIdentifier = SouncloudClient.clientIdentifier else {
            completion(SimpleAPIResponse(error: .credentialsNotSet))
            return
        }

        let url = BaseURL.appendingPathComponent("\(identifier).json")
        let parameters = ["client_id": clientIdentifier]

        let request = Request(url: url, method: .get, parameters: parameters, parse: {
            if let track = Track(JSON: $0) {
                return .success(track)
            }
            return .failure(.parsing)
        }) { result in
            completion(SimpleAPIResponse(result: result))
        }
        request.start()
    }

    /**
     Load tracks with specific identifiers

     - parameter identifiers: The identifiers of the tracks to load
     - parameter completion:  The closure that will be called when tracks are loaded or upon error
     */
    public static func tracks(identifiers: [Int], completion: @escaping (SimpleAPIResponse<[Track]>) -> Void) {
        guard let clientIdentifier = SouncloudClient.clientIdentifier else {
            completion(SimpleAPIResponse(error: .credentialsNotSet))
            return
        }

        let parameters = ["client_id": clientIdentifier, "ids": identifiers.map { "\($0)" }.joined(separator: ",")]
        let request = Request(url: BaseURL, method: .get, parameters: parameters, parse: {
            guard let tracks = $0.flatMap(transform: { Track(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(tracks)
        }) { result in
            completion(SimpleAPIResponse(result: result))
        }
        request.start()
    }

    /**
     Search tracks that fit asked queries.

     - parameter queries:    The queries to run
     - parameter completion: The closure that will be called when tracks are loaded or upon error
     */
    public static func search(queries: [SearchQueryOptions], completion: @escaping (PaginatedAPIResponse<Track>) -> Void) {
        guard let clientIdentifier = SouncloudClient.clientIdentifier else {
            completion(PaginatedAPIResponse(error: .credentialsNotSet))
            return
        }

        let parse = { (JSON: JSONObject) -> Result<[Track], SoundcloudError> in
            guard let tracks = JSON.flatMap(transform: { Track(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(tracks)
        }

        var parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]
        queries.map { $0.query }.forEach { parameters[$0.0] = $0.1 }

        let request = Request(url: BaseURL, method: .get, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Track>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON: JSON, parse: parse))
        }) { result in
            completion(result.result!)
        }
        request.start()
    }

    /**
     Load comments relative to a track

     - parameter trackIdentifier: The track identifier.
     - parameter completion:      The closure that will be called when the comments are loaded or upon error
     */
    public static func comments(on trackIdentifier: Int, completion: @escaping (PaginatedAPIResponse<Comment>) -> Void) {
        guard let clientIdentifier = SouncloudClient.clientIdentifier else {
            completion(PaginatedAPIResponse(error: .credentialsNotSet))
            return
        }

        let parse = { (JSON: JSONObject) -> Result<[Comment], SoundcloudError> in
            guard let comments = JSON.flatMap(transform: { Comment(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(comments)
        }

        let url = BaseURL.appendingPathComponent("\(trackIdentifier)/comments.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let request = Request(url: url, method: .get, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Comment>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON: JSON, parse: parse))
        }) { result in
            completion(result.result!)
        }
        request.start()
    }

    /**
     Load comments relative to a track

     - parameter completion: The closure that will be called when the comments are loaded or upon error
     */
    public func comments(completion: @escaping (PaginatedAPIResponse<Comment>) -> Void) {
        Track.comments(on: identifier, completion: completion)
    }

    /**
     Create a new comment on a track

     **This method requires a Session.**

     - parameter trackIdentifier: The track identifier.
     - parameter body:       The text body of the comment
     - parameter timestamp:  The progression of the track when the comment was validated
     - parameter completion: The closure that will be called when the comment is posted or upon error
     */
    @available(tvOS, unavailable)
    public static func comment(on trackIdentifier: Int, body: String, timestamp: TimeInterval, completion: @escaping (SimpleAPIResponse<Comment>) -> Void) {
        #if !os(tvOS)
        guard let clientIdentifier = SouncloudClient.clientIdentifier else {
            completion(SimpleAPIResponse(error: .credentialsNotSet))
            return
        }

        guard let oauthToken = SouncloudClient.session?.accessToken else {
            completion(SimpleAPIResponse(error: .needsLogin))
            return
        }

        let url = BaseURL.appendingPathComponent("\(trackIdentifier)/comments.json")
        let parameters = [
            "client_id": clientIdentifier,
            "comment[body]": body,
            "comment[timestamp]": "\(timestamp)",
            "oauth_token": oauthToken]

        let request = Request(url: url, method: .post, parameters: parameters, parse: {
            if let comments = Comment(JSON: $0) {
                return .success(comments)
            }
            return .failure(.parsing)
        }) { result in
            completion(SimpleAPIResponse(result: result))
        }
        request.start()
        #endif
    }

    /**
     Create a new comment on a track

     **This method requires a Session.**

     - parameter body:       The text body of the comment
     - parameter timestamp:  The progression of the track when the comment was validated
     - parameter completion: The closure that will be called when the comment is posted or upon error
     */
    @available(tvOS, unavailable)
    public func comment(body: String, timestamp: TimeInterval, completion: @escaping (SimpleAPIResponse<Comment>) -> Void) {
        #if !os(tvOS)
        Track.comment(on: identifier, body: body, timestamp: timestamp, completion: completion)
        #endif
    }

    /**
     Fetch the list of users that favorited the track.

     - parameter trackIdentifier: The track identifier.
     - parameter completion:      The closure that will be called when users are loaded or upon error
     */
    public static func favoriters(of trackIdentifier: Int, completion: @escaping (PaginatedAPIResponse<User>) -> Void) {
        guard let clientIdentifier = SouncloudClient.clientIdentifier else {
            completion(PaginatedAPIResponse(error: .credentialsNotSet))
            return
        }

        let url = BaseURL.appendingPathComponent("\(trackIdentifier)/favoriters.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[User], SoundcloudError> in
            guard let users = JSON.flatMap(transform: { User(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(users)
        }

        let request = Request(url: url, method: .get, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<User>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON: JSON, parse: parse))
        }) { result in
            completion(result.result!)
        }
        request.start()
    }

    /**
     Fetch the list of users that favorited the track.

     - parameter completion: The closure that will be called when users are loaded or upon error
     */
    public func favoriters(completion: @escaping (PaginatedAPIResponse<User>) -> Void) {
        Track.favoriters(of: identifier, completion: completion)
    }

    /**
     Favorites a track for the logged user

     **This method requires a Session.**

     - parameter trackIdentifier: The track identifier.
     - parameter completion:      The closure that will be called when the track has been favorited or upon error
     */
    @available(tvOS, unavailable)
    public static func favorite(trackIdentifier: Int, completion: @escaping (SimpleAPIResponse<Bool>) -> Void) {
        #if !os(tvOS)
        Track.changeFavoriteStatus(of: trackIdentifier, favorite: true, completion: completion)
        #endif
    }

    /**
     Favorites a track for the logged user

     **This method requires a Session.**

     - parameter completion: The closure that will be called when the track has been favorited or upon error
     */
    @available(tvOS, unavailable)
    public func favorite(completion: @escaping (SimpleAPIResponse<Bool>) -> Void) {
        #if !os(tvOS)
        Track.changeFavoriteStatus(of: identifier, favorite: true, completion: completion)
        #endif
    }

    /**
     Unfavorites a track for the logged user

     **This method requires a Session.**

     - parameter trackIdentifier: The track identifier.
     - parameter completion:      The closure that will be called when the track has been unfavorited or upon error
     */
    @available(tvOS, unavailable)
    public static func unfavorite(trackIdentifier: Int, completion: @escaping (SimpleAPIResponse<Bool>) -> Void) {
        #if !os(tvOS)
        Track.changeFavoriteStatus(of: trackIdentifier, favorite: false, completion: completion)
        #endif
    }

    /**
     Unfavorites a track for the logged user

     **This method requires a Session.**

     - parameter completion: The closure that will be called when the track has been unfavorited or upon error
     */
    @available(tvOS, unavailable)
    public func unfavorite(completion: @escaping (SimpleAPIResponse<Bool>) -> Void) {
        #if !os(tvOS)
        Track.changeFavoriteStatus(of: identifier, favorite: false, completion: completion)
        #endif
    }

    @available(tvOS, unavailable)
    private static func changeFavoriteStatus(of trackIdentifier: Int, favorite: Bool, completion: @escaping (SimpleAPIResponse<Bool>) -> Void) {
        #if !os(tvOS)
        guard let clientIdentifier = SouncloudClient.clientIdentifier else {
            completion(SimpleAPIResponse(error: .credentialsNotSet))
            return
        }

        guard let oauthToken = SouncloudClient.session?.accessToken else {
            completion(SimpleAPIResponse(error: .needsLogin))
            return
        }

        let parameters = ["client_id": clientIdentifier, "oauth_token": oauthToken]
        let url = User.BaseURL
            .appendingPathComponent("me/favorites/\(trackIdentifier).json")
            .appendingQueryString(parameters.queryString)

        let request = Request(url: url, method: favorite ? .put : .delete, parameters: nil, parse: { _ in
            return .success(true)
        }) { result in
            completion(SimpleAPIResponse(result: result))
        }
        request.start()
        #endif
    }

    /**
     Load related tracks of a track with a specific identifier

     - parameter identifier: The identifier of the track whose related tracks you wish to find
     - parameter completion: The closure that will be called when tracks are loaded or upon error
     */
    public static func relatedTracks(identifier: Int, completion: @escaping (SimpleAPIResponse<[Track]>) -> Void) {
        guard let clientIdentifier = SouncloudClient.clientIdentifier else {
            completion(SimpleAPIResponse(error: .credentialsNotSet))
            return
        }

        let url = BaseURL.appendingPathComponent("\(identifier)/related")
        let parameters = ["client_id": clientIdentifier]

        let request = Request(url: url, method: .get, parameters: parameters, parse: {
            guard let tracks = $0.flatMap(transform: { Track(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(tracks)
        }) { result in
            completion(SimpleAPIResponse(result: result))
        }
        request.start()
    }
}
