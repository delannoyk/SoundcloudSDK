//
//  UserRequest.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public extension User {
    static let BaseURL = URL(string: "https://api.soundcloud.com/users")!

    /**
     Loads an user profile

     - parameter identifier: The identifier of the user to load
     - parameter completion: The closure that will be called when user profile is loaded or upon error
     */
    public static func user(identifier: Int, completion: @escaping (SimpleAPIResponse<User>) -> Void) {
        guard let clientIdentifier = SessionManager.clientIdentifier else {
            completion(SimpleAPIResponse(error: .credentialsNotSet))
            return
        }

        let url = BaseURL.appendingPathComponent("\(identifier).json")
        let parameters = ["client_id": clientIdentifier]

        let request = Request(url: url, method: .get, parameters: parameters, parse: {
            if let user = User(JSON: $0) {
                return .success(user)
            }
            return .failure(.parsing)
        }) { result in
            completion(SimpleAPIResponse(result: result))
        }
        request.start()
    }

    /**
     Search users that fit requested name.

     - parameter query:      The query to run.
     - parameter completion: The closure that will be called when users are loaded or upon error.
     */
    public static func search(query: String, completion: @escaping (PaginatedAPIResponse<User>) -> Void) {
        guard let clientIdentifier = SessionManager.clientIdentifier else {
            completion(PaginatedAPIResponse(error: .credentialsNotSet))
            return
        }

        let parse = { (JSON: JSONObject) -> Result<[User], SoundcloudError> in
            guard let users = JSON.flatMap(transform: { User(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(users)
        }

        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true", "q": query]
        let request = Request(url: BaseURL, method: .get, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<User>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON: JSON, parse: parse))
        }) { result in
            completion(result.result!)
        }
        request.start()
    }

    /**
     Loads tracks the user uploaded to Soundcloud

     - parameter completion: The closure that will be called when tracks are loaded or upon error
     */
    public func tracks(completion: @escaping (PaginatedAPIResponse<Track>) -> Void) {
        User.tracks(from: identifier, completion: completion)
    }

    /**
     Loads tracks the user uploaded to Soundcloud

     - parameter userIdentifier: The identifier of the user to load
     - parameter completion:     The closure that will be called when tracks are loaded or upon error
     */
    public static func tracks(from userIdentifier: Int, completion: @escaping (PaginatedAPIResponse<Track>) -> Void) {
        guard let clientIdentifier = SessionManager.clientIdentifier else {
            completion(PaginatedAPIResponse(error: .credentialsNotSet))
            return
        }

        let url = BaseURL.appendingPathComponent("\(userIdentifier)/tracks.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[Track], SoundcloudError> in
            guard let tracks = JSON.flatMap(transform: { Track(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(tracks)
        }

        let request = Request(url: url, method: .get, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Track>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON: JSON, parse: parse))
        }) { result in
            completion(result.result!)
        }
        request.start()
    }

    /**
     Load all comments from the user

     - parameter completion: The closure that will be called when the comments are loaded or upon error
     */
    public func comments(completion: @escaping (PaginatedAPIResponse<Comment>) -> Void) {
        User.comments(from: identifier, completion: completion)
    }

    /**
     Load all comments from the user

     - parameter userIdentifier: The user identifier
     - parameter completion:     The closure that will be called when the comments are loaded or upon error
     */
    public static func comments(from userIdentifier: Int, completion: @escaping (PaginatedAPIResponse<Comment>) -> Void) {
        guard let clientIdentifier = SessionManager.clientIdentifier else {
            completion(PaginatedAPIResponse(error: .credentialsNotSet))
            return
        }

        let url = BaseURL.appendingPathComponent("\(userIdentifier)/comments.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[Comment], SoundcloudError> in
            guard let comments = JSON.flatMap(transform: { Comment(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(comments)
        }

        let request = Request(url: url, method: .get, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Comment>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON: JSON, parse: parse))
        }) { result in
            completion(result.result!)
        }
        request.start()
    }

    /**
     Loads favorited tracks of the user

     - parameter completion: The closure that will be called when tracks are loaded or upon error
     */
    public func favorites(completion: @escaping (PaginatedAPIResponse<Track>) -> Void) {
        User.favorites(from: identifier, completion: completion)
    }

    /**
     Loads favorited tracks of the user

     - parameter userIdentifier: The user identifier
     - parameter completion:     The closure that will be called when tracks are loaded or upon error
     */
    public static func favorites(from userIdentifier: Int, completion: @escaping (PaginatedAPIResponse<Track>) -> Void) {
        guard let clientIdentifier = SessionManager.clientIdentifier else {
            completion(PaginatedAPIResponse(error: .credentialsNotSet))
            return
        }

        let url = BaseURL.appendingPathComponent("\(userIdentifier)/favorites.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[Track], SoundcloudError> in
            guard let tracks = JSON.flatMap(transform: { Track(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(tracks)
        }

        let request = Request(url: url, method: .get, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Track>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON: JSON, parse: parse))
        }) { result in
            completion(result.result!)
        }
        request.start()
    }

    /**
     Loads followers of the user

     - parameter completion: The closure that will be called when followers are loaded or upon error
     */
    public func followers(completion: @escaping (PaginatedAPIResponse<User>) -> Void) {
        User.followers(from: identifier, completion: completion)
    }

    /**
     Loads followers of the user

     - parameter userIdentifier: The user identifier
     - parameter completion: The closure that will be called when followers are loaded or upon error
     */
    public static func followers(from userIdentifier: Int, completion: @escaping (PaginatedAPIResponse<User>) -> Void) {
        guard let clientIdentifier = SessionManager.clientIdentifier else {
            completion(PaginatedAPIResponse(error: .credentialsNotSet))
            return
        }

        let url = User.BaseURL.appendingPathComponent("\(userIdentifier)/followers.json")
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
     Loads followed users of the user

     - parameter completion: The closure that will be called when followed users are loaded or upon error
     */
    public func followings(completion: @escaping (PaginatedAPIResponse<User>) -> Void) {
        User.followings(from: identifier, completion: completion)
    }

    /**
     Loads followed users of the user

     - parameter userIdentifier: The user identifier
     - parameter completion: The closure that will be called when followed users are loaded or upon error
     */
    public static func followings(from userIdentifier: Int, completion: @escaping (PaginatedAPIResponse<User>) -> Void) {
        guard let clientIdentifier = SessionManager.clientIdentifier else {
            completion(PaginatedAPIResponse(error: .credentialsNotSet))
            return
        }

        let url = User.BaseURL.appendingPathComponent("\(userIdentifier)/followings.json")
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
     Follow the given user.

     **This method requires a Session.**

     - parameter userIdentifier: The identifier of the user to follow
     - parameter completion:     The closure that will be called when the user has been followed or upon error
     */
    @available(tvOS, unavailable)
    public func follow(userIdentifier: Int, completion: @escaping (SimpleAPIResponse<Bool>) -> Void) {
        #if !os(tvOS)
        User.changeFollowStatus(follow: true, userIdentifier: userIdentifier, completion: completion)
        #endif
    }

    /**
     Follow the given user.

     **This method requires a Session.**

     - parameter userIdentifier: The identifier of the user to follow
     - parameter completion:     The closure that will be called when the user has been followed or upon error
     */
    @available(tvOS, unavailable)
    public static func follow(userIdentifier: Int, completion: @escaping (SimpleAPIResponse<Bool>) -> Void) {
        #if !os(tvOS)
        User.changeFollowStatus(follow: true, userIdentifier: userIdentifier, completion: completion)
        #endif
    }

    /**
     Unfollow the given user.

     **This method requires a Session.**

     - parameter userIdentifier: The identifier of the user to unfollow
     - parameter completion:     The closure that will be called when the user has been unfollowed or upon error
     */
    @available(tvOS, unavailable)
    public func unfollow(userIdentifier: Int, completion: @escaping (SimpleAPIResponse<Bool>) -> Void) {
        #if !os(tvOS)
        User.changeFollowStatus(follow: false, userIdentifier: userIdentifier, completion: completion)
        #endif
    }

    /**
     Unfollow the given user.

     **This method requires a Session.**

     - parameter userIdentifier: The identifier of the user to unfollow
     - parameter completion:     The closure that will be called when the user has been unfollowed or upon error
     */
    @available(tvOS, unavailable)
    public static func unfollow(userIdentifier: Int, completion: @escaping (SimpleAPIResponse<Bool>) -> Void) {
        #if !os(tvOS)
        User.changeFollowStatus(follow: false, userIdentifier: userIdentifier, completion: completion)
        #endif
    }

    @available(tvOS, unavailable)
    static func changeFollowStatus(follow: Bool, userIdentifier: Int, completion: @escaping (SimpleAPIResponse<Bool>) -> Void) {
        #if !os(tvOS)
        guard let clientIdentifier = SessionManager.clientIdentifier else {
            completion(SimpleAPIResponse(error: .credentialsNotSet))
            return
        }

        guard let oauthToken = SessionManager.session?.accessToken else {
            completion(SimpleAPIResponse(error: .needsLogin))
            return
        }

        let parameters = ["client_id": clientIdentifier, "oauth_token": oauthToken]
        let url = BaseURL
            .deletingLastPathComponent()
            .appendingPathComponent("me/followings/\(userIdentifier).json")
            .appendingQueryString(parameters.queryString)

        let request = Request(url: url, method: follow ? .put : .delete, parameters: nil, parse: { _ in
            return .success(true)
        }) { result in
            completion(SimpleAPIResponse(result: result))
        }
        request.start()
        #endif
    }

    /**
     Loads user's playlists

     - parameter completion: The closure that will be called when playlists has been loaded or upon error
     */
    public func playlists(completion: @escaping (PaginatedAPIResponse<Playlist>) -> Void) {
        User.playlists(from: identifier, completion: completion)
    }

    /**
     Loads user's playlists

     - parameter userIdentifier: The identifier of the user to unfollow
     - parameter completion: The closure that will be called when playlists has been loaded or upon error
     */
    public static func playlists(from userIdentifier: Int, completion: @escaping (PaginatedAPIResponse<Playlist>) -> Void) {
        guard let clientIdentifier = SessionManager.clientIdentifier else {
            completion(PaginatedAPIResponse(error: .credentialsNotSet))
            return
        }

        let url = BaseURL.appendingPathComponent("\(userIdentifier)/playlists.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[Playlist], SoundcloudError> in
            guard let playlists = JSON.flatMap(transform: { Playlist(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(playlists)
        }

        let request = Request(url: url, method: .get, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Playlist>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON: JSON, parse: parse))
        }) { result in
            completion(result.result!)
        }
        request.start()
    }
}
