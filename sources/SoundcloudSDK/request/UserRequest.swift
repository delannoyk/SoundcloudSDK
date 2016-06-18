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
    public static func user(identifier: Int, completion: (SimpleAPIResponse<User>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }

        let url = try! User.BaseURL.appendingPathComponent("\(identifier).json")
        let parameters = ["client_id": clientIdentifier]

        let request = Request(url: url, method: .GET, parameters: parameters, parse: {
            if let user = User(JSON: $0) {
                return .success(user)
            }
            return .failure(.Parsing)
            }) { result in
                completion(SimpleAPIResponse(result))
        }
        request.start()
    }

    /**
    Loads tracks the user uploaded to Soundcloud

    - parameter completion: The closure that will be called when tracks are loaded or upon error
    */
    public func tracks(completion: (PaginatedAPIResponse<Track>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(PaginatedAPIResponse(.CredentialsNotSet))
            return
        }

        let url = try! User.BaseURL.appendingPathComponent("\(identifier)/tracks.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[Track], SoundcloudError> in
            guard let tracks = JSON.flatMap({ return Track(JSON: $0) }) else {
                return .failure(.Parsing)
            }
            return .success(tracks)
        }

        let request = Request(url: url, method: .GET, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Track>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON, parse: parse))
            }) { result in
                completion(result.result!)
        }
        request.start()
    }

    /**
    Load all comments from the user

    - parameter completion: The closure that will be called when the comments are loaded or upon error
    */
    public func comments(completion: (PaginatedAPIResponse<Comment>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(PaginatedAPIResponse(.CredentialsNotSet))
            return
        }

        let url = try! User.BaseURL.appendingPathComponent("\(identifier)/comments.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[Comment], SoundcloudError> in
            guard let comments = JSON.flatMap({ return Comment(JSON: $0) }) else {
                return .failure(.Parsing)
            }
            return .success(comments)
        }

        let request = Request(url: url, method: .GET, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Comment>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON, parse: parse))
            }) { result in
                completion(result.result!)
        }
        request.start()
    }

    /**
    Loads favorited tracks of the user

    - parameter completion: The closure that will be called when tracks are loaded or upon error
    */
    public func favorites(completion: (PaginatedAPIResponse<Track>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(PaginatedAPIResponse(.CredentialsNotSet))
            return
        }

        let url = try! User.BaseURL.appendingPathComponent("\(identifier)/favorites.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[Track], SoundcloudError> in
            guard let tracks = JSON.flatMap({ return Track(JSON: $0) }) else {
                return .failure(.Parsing)
            }
            return .success(tracks)
        }

        let request = Request(url: url, method: .GET, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Track>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON, parse: parse))
            }) { result in
                completion(result.result!)
        }
        request.start()
    }

    /**
    Loads followers of the user

    - parameter completion: The closure that will be called when followers are loaded or upon error
    */
    public func followers(completion: (PaginatedAPIResponse<User>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(PaginatedAPIResponse(.CredentialsNotSet))
            return
        }

        let url = try! User.BaseURL.appendingPathComponent("\(identifier)/followers.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[User], SoundcloudError> in
            guard let users = JSON.flatMap({ return User(JSON: $0) }) else {
                return .failure(.Parsing)
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

    /**
    Loads followed users of the user

    - parameter completion: The closure that will be called when followed users are loaded or upon error
    */
    public func followings(completion: (PaginatedAPIResponse<User>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(PaginatedAPIResponse(.CredentialsNotSet))
            return
        }

        let url = try! User.BaseURL.appendingPathComponent("\(identifier)/followings.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[User], SoundcloudError> in
            guard let users = JSON.flatMap({ return User(JSON: $0) }) else {
                return .failure(.Parsing)
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
    Follow the given user.

    **This method requires a Session.**

    - parameter userIdentifier: The identifier of the user to follow
    - parameter completion:     The closure that will be called when the user has been followed or upon error
    */
    public func follow(userIdentifier: Int, completion: (SimpleAPIResponse<Bool>) -> Void) {
        changeFollowStatus(follow: true, userIdentifier: userIdentifier, completion: completion)
    }

    /**
    Follow the given user.

    **This method requires a Session.**

    - parameter userIdentifier: The identifier of the user to unfollow
    - parameter completion:     The closure that will be called when the user has been unfollowed or upon error
    */
    public func unfollow(userIdentifier: Int, completion: (SimpleAPIResponse<Bool>) -> Void) {
        changeFollowStatus(follow: false, userIdentifier: userIdentifier, completion: completion)
    }

    func changeFollowStatus(follow: Bool, userIdentifier: Int, completion: (SimpleAPIResponse<Bool>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }

        guard let oauthToken = Soundcloud.session?.accessToken else {
            completion(SimpleAPIResponse(.NeedsLogin))
            return
        }

        let parameters = ["client_id": clientIdentifier, "oauth_token": oauthToken]
        let url = try! User.BaseURL.deletingLastPathComponent().appendingPathComponent("me/followings/\(userIdentifier).json").appendingQueryString(parameters.queryString)

        let request = Request(url: url, method: follow ? .PUT : .DELETE, parameters: nil, parse: { _ in
            return .success(true)
            }) { result in
                completion(SimpleAPIResponse(result))
        }
        request.start()
    }
    #endif

    /**
    Loads user's playlists

    - parameter completion: The closure that will be called when playlists has been loaded or upon error
    */
    public func playlists(completion: (PaginatedAPIResponse<Playlist>) -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(PaginatedAPIResponse(.CredentialsNotSet))
            return
        }

        let url = try! User.BaseURL.appendingPathComponent("\(identifier)/playlists.json")
        let parameters = ["client_id": clientIdentifier, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[Playlist], SoundcloudError> in
            guard let playlists = JSON.flatMap({ return Playlist(JSON: $0) }) else {
                return .failure(.Parsing)
            }
            return .success(playlists)
        }

        let request = Request(url: url, method: .GET, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Playlist>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON, parse: parse))
            }) { result in
                completion(result.result!)
        }
        request.start()
    }
}
