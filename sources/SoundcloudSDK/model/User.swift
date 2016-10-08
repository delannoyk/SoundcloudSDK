//
//  User.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public struct User {
    ///User's identifier
    public let identifier: Int

    ///Username
    public let username: String

    ///First and Last name
    public let fullname: String

    ///The city
    public let city: String?

    ///The country
    public let country: String?

    ///User's description
    public let biography: String?

    ///URL to user (website)
    public let permalinkURL: URL?

    ///URL to user's website
    public let websiteURL: URL?

    ///Title of user's website
    public let websiteTitle: String?

    ///URL to a JPEG image
    public let avatarURL: ImageURLs

    ///Number of public tracks
    public let tracksCount: Int

    ///Number of public playlists
    public let playlistsCount: Int

    ///Number of followers
    public let followersCount: Int

    ///Number of followed users
    public let followingsCount: Int
}

// MARK: Parsing

extension User {
    init?(JSON: JSONObject) {
        guard let identifier = JSON["id"].intValue, let username = JSON["username"].stringValue else {
            return nil
        }

        self.identifier = identifier
        self.username = username
        self.fullname = JSON["full_name"].stringValue ?? ""
        self.city = JSON["city"].stringValue
        self.country = JSON["country"].stringValue
        self.biography = JSON["description"].stringValue
        self.permalinkURL = JSON["permalink_url"].urlValue
        self.websiteURL = JSON["website"].urlValue
        self.websiteTitle = JSON["website_title"].stringValue
        self.avatarURL = ImageURLs(baseURL: JSON["avatar_url"].urlValue)
        self.tracksCount = JSON["track_count"].intValue ?? 0
        self.playlistsCount = JSON["playlist_count"].intValue ?? 0
        self.followersCount = JSON["followers_count"].intValue ?? 0
        self.followingsCount = JSON["followings_count"].intValue ?? 0
    }
}

// MARK: Equatable

extension User: Equatable {}

/**
 Compares 2 Users based on their identifier

 - parameter lhs: First user
 - parameter rhs: Second user

 - returns: true if users are equals, false if they're not
 */
public func ==(lhs: User, rhs: User) -> Bool {
    return lhs.identifier == rhs.identifier
}
