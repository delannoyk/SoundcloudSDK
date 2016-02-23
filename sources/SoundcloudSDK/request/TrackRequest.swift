//
//  TrackRequest.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public extension Track {
    internal static let BaseURL = NSURL(string: "https://api.soundcloud.com/tracks")!

    /**
    Load track with a specific identifier

    - parameter identifier: The identifier of the track to load
    - parameter completion: The closure that will be called when track is loaded or upon error
    */
    public static func track(identifier: Int, completion: SimpleAPIResponse<Track> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }

        let URL = BaseURL.URLByAppendingPathComponent("\(identifier).json")
        let parameters = ["client_id": clientIdentifier]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            if let track = Track(JSON: $0) {
                return .Success(track)
            }
            return .Failure(.Parsing)
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
    public static func tracks(identifiers: [Int], completion: SimpleAPIResponse<[Track]> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }

        let parameters = ["client_id": clientIdentifier, "ids": identifiers.map { "\($0)" }.joinWithSeparator(",")]
        let request = Request(URL: BaseURL, method: .GET, parameters: parameters, parse: {
            guard let tracks = $0.flatMap({ return Track(JSON: $0) }) else {
                return .Failure(.Parsing)
            }
            return .Success(tracks)
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
    public static func search(queries: [SearchQueryOptions], completion: PaginatedAPIResponse<Track> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(PaginatedAPIResponse(.CredentialsNotSet))
            return
        }

        let parse = { (JSON: JSONObject) -> Result<[Track], SoundcloudError> in
            guard let tracks = JSON.flatMap({ return Track(JSON: $0) }) else {
                return .Failure(.Parsing)
            }
            return .Success(tracks)
        }

        var parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]
        queries.map { $0.query }.forEach { parameters[$0.0] = $0.1 }

        let request = Request(URL: BaseURL, method: .GET, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Track>, SoundcloudError> in
            return .Success(PaginatedAPIResponse(JSON, parse: parse))
            }) { result in
                completion(result.result!)
        }
        request.start()
    }

    /**
    Load comments relative to a track

    - parameter completion: The closure that will be called when the comments are loaded or upon error
    */
    public func comments(completion: PaginatedAPIResponse<Comment> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(PaginatedAPIResponse(.CredentialsNotSet))
            return
        }

        let parse = { (JSON: JSONObject) -> Result<[Comment], SoundcloudError> in
            guard let comments = JSON.flatMap({ return Comment(JSON: $0) }) else {
                return .Failure(.Parsing)
            }
            return .Success(comments)
        }

        let URL = Track.BaseURL.URLByAppendingPathComponent("\(identifier)/comments.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Comment>, SoundcloudError> in
            return .Success(PaginatedAPIResponse(JSON, parse: parse))
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
    public func comment(body: String, timestamp: NSTimeInterval, completion: SimpleAPIResponse<Comment> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }

        guard let oauthToken = Soundcloud.session?.accessToken else {
            completion(SimpleAPIResponse(.NeedsLogin))
            return
        }

        let URL = Track.BaseURL.URLByAppendingPathComponent("\(identifier)/comments.json")
        let parameters = ["client_id": clientIdentifier, "comment[body]": body, "comment[timestamp]": "\(timestamp)", "oauth_token": oauthToken]

        let request = Request(URL: URL, method: .POST, parameters: parameters, parse: {
            if let comments = Comment(JSON: $0) {
                return .Success(comments)
            }
            return .Failure(.Parsing)
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
    public func favoriters(completion: PaginatedAPIResponse<User> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(PaginatedAPIResponse(.CredentialsNotSet))
            return
        }

        let URL = Track.BaseURL.URLByAppendingPathComponent("\(identifier)/favoriters.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[User], SoundcloudError> in
            guard let users = JSON.flatMap({ return User(JSON: $0) }) else {
                return .Failure(.Parsing)
            }
            return .Success(users)
        }

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<User>, SoundcloudError> in
            return .Success(PaginatedAPIResponse(JSON, parse: parse))
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
    public func favorite(userIdentifier: Int, completion: SimpleAPIResponse<Bool> -> Void) {
        changeFavoriteStatus(true, userIdentifier: userIdentifier, completion: completion)
    }

    /**
     Unfavorites a track for the logged user
     
     **This method requires a Session.**

     - parameter userIdentifier: The identifier of the logged user
     - parameter completion:     The closure that will be called when the track has been unfavorited or upon error
     */
    public func unfavorite(userIdentifier: Int, completion: SimpleAPIResponse<Bool> -> Void) {
        changeFavoriteStatus(false, userIdentifier: userIdentifier, completion: completion)
    }

    private func changeFavoriteStatus(favorite: Bool, userIdentifier: Int, completion: SimpleAPIResponse<Bool> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }

        guard let oauthToken = Soundcloud.session?.accessToken else {
            completion(SimpleAPIResponse(.NeedsLogin))
            return
        }

        let parameters = ["client_id": clientIdentifier, "oauth_token": oauthToken]
        let URL = User.BaseURL.URLByAppendingPathComponent("\(userIdentifier)/favorites/\(identifier).json")
            .URLByAppendingQueryString(parameters.queryString)

        let request = Request(URL: URL, method: favorite ? .PUT : .DELETE, parameters: nil, parse: { _ in
            return .Success(true)
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
    public static func relatedTracks(identifier: Int, completion: SimpleAPIResponse<[Track]> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }
        
        let URL = BaseURL.URLByAppendingPathComponent("\(identifier)/related")
        let parameters = ["client_id": clientIdentifier]
        
        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            guard let tracks = $0.flatMap({ return Track(JSON: $0) }) else {
                return .Failure(.Parsing)
            }
            return .Success(tracks)
            }) { result in
                completion(SimpleAPIResponse(result))
        }
        request.start()
    }
}
