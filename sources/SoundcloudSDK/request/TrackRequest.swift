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
    public static func track(_ identifier: Int, completion: @escaping (SimpleAPIResponse<Track>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.credentialsNotSet))
            return
        }

        let url = BaseURL.appendingPathComponent("\(identifier).json")
        let parameters = ["client_id": clientIdentifier]

        let request = Request(url: url, method: .GET, parameters: parameters, parse: {
            if let track = Track(JSON: $0) {
                return .success(track)
            }
            return .failure(.parsing)
            }) { result in
                completion(SimpleAPIResponse(result))
        }
        request.start()
    }

    /**
    Load tracks with specific identifiers

    - parameter identifiers: The identifiers of the tracks to load
    - parameter completion:  The closure that will be called when tracks are loaded or upon error
    */
    public static func tracks(_ identifiers: [Int], completion: @escaping (SimpleAPIResponse<[Track]>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.credentialsNotSet))
            return
        }

        let parameters = ["client_id": clientIdentifier, "ids": identifiers.map { "\($0)" }.joined(separator: ",")]
        let request = Request(url: BaseURL, method: .GET, parameters: parameters, parse: {
            guard let tracks = $0.flatMap({ return Track(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(tracks)
            }) { result in
                completion(SimpleAPIResponse(result))
        }
        request.start()
    }

    /**
    Search tracks that fit asked queries.
    
    - parameter queries:    The queries to run
    - parameter completion: The closure that will be called when tracks are loaded or upon error
    */
    public static func search(_ queries: [SearchQueryOptions], completion: @escaping (PaginatedAPIResponse<Track>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(PaginatedAPIResponse(.credentialsNotSet))
            return
        }

        let parse = { (JSON: JSONObject) -> Result<[Track], SoundcloudError> in
            guard let tracks = JSON.flatMap({ return Track(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(tracks)
        }

        var parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]
        queries.map { $0.query }.forEach { parameters[$0.0] = $0.1 }

        let request = Request(url: BaseURL, method: .GET, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Track>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON, parse: parse))
            }) { result in
                completion(result.result!)
        }
        request.start()
    }

    /**
    Load comments relative to a track

    - parameter completion: The closure that will be called when the comments are loaded or upon error
    */
    public func comments(_ completion: @escaping (PaginatedAPIResponse<Comment>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(PaginatedAPIResponse(.credentialsNotSet))
            return
        }

        let parse = { (JSON: JSONObject) -> Result<[Comment], SoundcloudError> in
            guard let comments = JSON.flatMap({ return Comment(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(comments)
        }

        let url = Track.BaseURL.appendingPathComponent("\(identifier)/comments.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let request = Request(url: url, method: .GET, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Comment>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON, parse: parse))
            }) { result in
                completion(result.result!)
        }
        request.start()
    }

    #if os(iOS) || os(OSX)
    /**
    Create a new comment on a track
    
    **This method requires a Session.**

    - parameter body:       The text body of the comment
    - parameter timestamp:  The progression of the track when the comment was validated
    - parameter completion: The closure that will be called when the comment is posted or upon error
    */
    public func comment(_ body: String, timestamp: TimeInterval, completion: @escaping (SimpleAPIResponse<Comment>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.credentialsNotSet))
            return
        }

        guard let oauthToken = Soundcloud.session?.accessToken else {
            completion(SimpleAPIResponse(.needsLogin))
            return
        }

        let url = Track.BaseURL.appendingPathComponent("\(identifier)/comments.json")
        let parameters = ["client_id": clientIdentifier, "comment[body]": body, "comment[timestamp]": "\(timestamp)", "oauth_token": oauthToken]

        let request = Request(url: url, method: .POST, parameters: parameters, parse: {
            if let comments = Comment(JSON: $0) {
                return .success(comments)
            }
            return .failure(.parsing)
            }) { result in
                completion(SimpleAPIResponse(result))
        }
        request.start()
    }
    #endif

    /**
    Fetch the list of users that favorited the track.

    - parameter completion: The closure that will be called when users are loaded or upon error
    */
    public func favoriters(_ completion: @escaping (PaginatedAPIResponse<User>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(PaginatedAPIResponse(.credentialsNotSet))
            return
        }

        let url = Track.BaseURL.appendingPathComponent("\(identifier)/favoriters.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[User], SoundcloudError> in
            guard let users = JSON.flatMap({ return User(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(users)
        }

        let request = Request(url: url, method: .GET, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<User>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON, parse: parse))
            }) { result in
                completion(result.result!)
        }
        request.start()
    }

    #if os(iOS) || os(OSX)
    /**
    Favorites a track for the logged user
    
    **This method requires a Session.**

    - parameter userIdentifier: The identifier of the logged user
    - parameter completion:     The closure that will be called when the track has been favorited or upon error
    */
    public func favorite(_ userIdentifier: Int, completion: @escaping (SimpleAPIResponse<Bool>) -> Void) {
        changeFavoriteStatus(true, userIdentifier: userIdentifier, completion: completion)
    }

    /**
     Unfavorites a track for the logged user
     
     **This method requires a Session.**

     - parameter userIdentifier: The identifier of the logged user
     - parameter completion:     The closure that will be called when the track has been unfavorited or upon error
     */
    public func unfavorite(_ userIdentifier: Int, completion: @escaping (SimpleAPIResponse<Bool>) -> Void) {
        changeFavoriteStatus(false, userIdentifier: userIdentifier, completion: completion)
    }

    fileprivate func changeFavoriteStatus(_ favorite: Bool, userIdentifier: Int, completion: @escaping (SimpleAPIResponse<Bool>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.credentialsNotSet))
            return
        }

        guard let oauthToken = Soundcloud.session?.accessToken else {
            completion(SimpleAPIResponse(.needsLogin))
            return
        }

        let parameters = ["client_id": clientIdentifier, "oauth_token": oauthToken]
        let url = User.BaseURL.appendingPathComponent("\(userIdentifier)/favorites/\(identifier).json").appendingQueryString(parameters.queryString)

        let request = Request(url: url, method: favorite ? .PUT : .DELETE, parameters: nil, parse: { _ in
            return .success(true)
            }) { result in
                completion(SimpleAPIResponse(result))
        }
        request.start()
    }
    #endif
    
    /**
     Load related tracks of a track with a specific identifier
     
     - parameter identifier: The identifier of the track whose related tracks you wish to find
     - parameter completion: The closure that will be called when tracks are loaded or upon error
     */
    public static func relatedTracks(_ identifier: Int, completion: @escaping (SimpleAPIResponse<[Track]>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.credentialsNotSet))
            return
        }
        
        let url = BaseURL.appendingPathComponent("\(identifier)/related")
        let parameters = ["client_id": clientIdentifier]
        
        let request = Request(url: url, method: .GET, parameters: parameters, parse: {
            guard let tracks = $0.flatMap({ return Track(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(tracks)
            }) { result in
                completion(SimpleAPIResponse(result))
        }
        request.start()
    }
}
