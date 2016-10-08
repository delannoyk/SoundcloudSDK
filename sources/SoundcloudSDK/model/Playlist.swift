//
//  Playlist.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public struct Playlist {
    ///Playlist's identifier
    public let identifier: Int

    ///Date of creation
    public let createdAt: Date

    ///Mini user representation of the owner
    public let createdBy: User

    ///Duration
    public let duration: TimeInterval

    ///Streamable via API (This will aggregate the playlists tracks streamable attribute.
    ///Its value will be false if not all tracks have the same streamable value.)
    public let streamable: Bool

    ///Downloadable (This will aggregate the playlists tracks downloadable attribute.
    ///Its value will be false if not all tracks have the same downloadable value.)
    public let downloadable: Bool

    ///URL to the SoundCloud.com page
    public let permalinkURL: URL?

    ///External purchase link
    public let purchaseURL: URL?

    ///Release year
    public let releaseYear: Int?

    ///Release month
    public let releaseMonth: Int?

    ///Release day
    public let releaseDay: Int?

    ///Release number
    public let releaseNumber: String?

    ///HTML description
    public let description: String?

    ///Genre
    public let genre: String?

    ///Playlist type
    public let type: PlaylistType?

    ///Track title
    public let title: String

    ///URL to a JPEG image
    public let artworkURL: ImageURLs

    ///Tracks
    public let tracks: [Track]

    ///EAN identifier for the playlist
    public let ean: String?

    ///public/private sharing
    public let sharingAccess: SharingAccess

    ///Identifier of the label user
    public let labelIdentifier: Int?

    ///Label name
    public let labelName: String?

    ///Creative common license
    public let license: String?
}

// MARK: Equatable

extension Playlist: Equatable {}

/**
Compares 2 Playlists based on their identifier

- parameter lhs: First playlist
- parameter rhs: Second playlist

- returns: true if playlists are equals, false if they're not
*/
public func ==(lhs: Playlist, rhs: Playlist) -> Bool {
    return lhs.identifier == rhs.identifier
}

// MARK: Parsing

extension Playlist {
    init?(JSON: JSONObject) {
        guard let identifier = JSON["id"].intValue, let user = User(JSON: JSON["user"]), JSON["kind"].stringValue == "playlist" else {
            return nil
        }

        self.identifier = identifier
        self.createdAt = JSON["created_at"].dateValue(format: "yyyy/MM/dd HH:mm:ss VVVV") ?? Date()
        self.createdBy = user
        self.duration = JSON["duration"].doubleValue.map { $0 / 1000 } ?? 0
        self.streamable = JSON["streamable"].boolValue ?? false
        self.downloadable = JSON["downloadable"].boolValue ?? false
        self.permalinkURL = JSON["permalink_url"].urlValue
        self.purchaseURL = JSON["purchase_url"].urlValue
        self.releaseYear = JSON["release_year"].intValue
        self.releaseMonth = JSON["release_month"].intValue
        self.releaseDay = JSON["release_day"].intValue
        self.releaseNumber = JSON["release"].stringValue
        self.description = JSON["description"].stringValue
        self.genre = JSON["genre"].stringValue
        self.type = PlaylistType(rawValue: JSON["playlist_type"].stringValue ?? "")
        self.title = JSON["title"].stringValue ?? ""
        self.artworkURL = ImageURLs(baseURL: JSON["artwork_url"].urlValue)
        self.tracks = JSON["tracks"].flatMap { Track(JSON: $0) } ?? []
        self.ean = JSON["ean"].stringValue
        self.sharingAccess = SharingAccess(rawValue: JSON["sharing"].stringValue ?? "") ?? .private
        self.labelIdentifier = JSON["label_id"].intValue
        self.labelName = JSON["label_name"].stringValue
        self.license = JSON["license"].stringValue
    }
}
