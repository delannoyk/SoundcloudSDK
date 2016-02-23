//
//  User.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

// MARK: - User's definition
////////////////////////////////////////////////////////////////////////////

public struct User {
    public init(identifier: Int, username: String, fullname: String,
        city: String?, country: String?, biography: String?,
        URL: NSURL?, permalinkURL: NSURL?, websiteURL: NSURL?,
        websiteTitle: String?, avatarURL: ImageURLs, tracksCount: Int,
        playlistsCount: Int, followersCount: Int, followingsCount: Int) {
            self.identifier = identifier

            self.username = username
            self.fullname = fullname
            self.city = city
            self.country = country
            self.biography = biography

            self.URL = URL
            self.permalinkURL = permalinkURL
            self.websiteURL = websiteURL
            self.websiteTitle = websiteTitle

            self.avatarURL = avatarURL

            self.tracksCount = tracksCount
            self.playlistsCount = playlistsCount
            self.followersCount = followersCount
            self.followingsCount = followingsCount
    }

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


    ///URL to user (api)
    internal let URL: NSURL?

    ///URL to user (website)
    public let permalinkURL: NSURL?

    ///URL to user's website
    public let websiteURL: NSURL?

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

////////////////////////////////////////////////////////////////////////////


// MARK: - User Extensions
////////////////////////////////////////////////////////////////////////////

// MARK: Parsing
////////////////////////////////////////////////////////////////////////////

internal extension User {
    init?(JSON: JSONObject) {
        if let identifier = JSON["id"].intValue, username = JSON["username"].stringValue {
            self.init(
                identifier: identifier,
                username: username,
                fullname: JSON["full_name"].stringValue ?? "",
                city: JSON["city"].stringValue,
                country: JSON["country"].stringValue,
                biography: JSON["description"].stringValue,
                URL: JSON["uri"].urlValue,
                permalinkURL: JSON["permalink_url"].urlValue,
                websiteURL: JSON["website"].urlValue,
                websiteTitle: JSON["website_title"].stringValue,
                avatarURL: ImageURLs(baseURL: JSON["avatar_url"].urlValue),
                tracksCount: JSON["track_count"].intValue ?? 0,
                playlistsCount: JSON["playlist_count"].intValue ?? 0,
                followersCount: JSON["followers_count"].intValue ?? 0,
                followingsCount: JSON["followings_count"].intValue ?? 0
            )
        }
        else {
            return nil
        }
    }
}

////////////////////////////////////////////////////////////////////////////


// MARK: Equatable
////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
