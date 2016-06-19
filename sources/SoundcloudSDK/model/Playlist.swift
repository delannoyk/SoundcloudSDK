//
//  Playlist.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

// MARK: - Playlist's definition
////////////////////////////////////////////////////////////////////////////

public struct Playlist {
    public init(identifier: Int, createdAt: NSDate, createdBy: User, duration: NSTimeInterval,
        streamable: Bool, downloadable: Bool, permalinkURL: NSURL?, purchaseURL: NSURL?,
        releaseYear: Int?, releaseMonth: Int?, releaseDay: Int?, releaseNumber: String?,
        description: String?, genre: String?, type: PlaylistType?, title: String,
        artworkURL: ImageURLs, tracks: [Track], ean: String?, sharingAccess: SharingAccess,
        labelIdentifier: Int?, labelName: String?, license: String?) {
            self.identifier = identifier

            self.createdAt = createdAt
            self.createdBy = createdBy

            self.duration = duration

            self.streamable = streamable
            self.downloadable = downloadable

            self.permalinkURL = permalinkURL
            self.purchaseURL = purchaseURL

            self.releaseYear = releaseYear
            self.releaseMonth = releaseMonth
            self.releaseDay = releaseDay
            self.releaseNumber = releaseNumber

            self.description = description
            self.genre = genre
            self.type = type
            self.title = title
            self.artworkURL = artworkURL

            self.tracks = tracks

            self.ean = ean
            self.sharingAccess = sharingAccess
            self.labelIdentifier = labelIdentifier
            self.labelName = labelName
            self.license = license
    }

    ///Playlist's identifier
    public let identifier: Int


    ///Date of creation
    public let createdAt: NSDate

    ///Mini user representation of the owner
    public let createdBy: User


    ///Duration
    public let duration: NSTimeInterval


    ///Streamable via API (This will aggregate the playlists tracks streamable attribute.
    ///Its value will be nil if not all tracks have the same streamable value.)
    public let streamable: Bool

    ///Downloadable (This will aggregate the playlists tracks downloadable attribute.
    ///Its value will be nil if not all tracks have the same downloadable value.)
    public let downloadable: Bool


    ///URL to the SoundCloud.com page
    public let permalinkURL: NSURL?

    ///External purchase link
    public let purchaseURL: NSURL?


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

////////////////////////////////////////////////////////////////////////////


// MARK: - Equatable
////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////


// MARK: Parsing
////////////////////////////////////////////////////////////////////////////

internal extension Playlist {
    init?(JSON: JSONObject) {
        if let identifier = JSON["id"].intValue, user = User(JSON: JSON["user"]) where JSON["kind"].stringValue == "playlist" {
            self.init(identifier: identifier,
                createdAt: JSON["created_at"].dateValue("yyyy/MM/dd HH:mm:ss VVVV") ?? NSDate(),
                createdBy: user,
                duration: JSON["duration"].doubleValue.map { $0 / 1000 } ?? 0,
                streamable: JSON["streamable"].boolValue ?? false,
                downloadable: JSON["downloadable"].boolValue ?? false,
                permalinkURL: JSON["permalink_url"].urlValue,
                purchaseURL: JSON["purchase_url"].urlValue,
                releaseYear: JSON["release_year"].intValue,
                releaseMonth: JSON["release_month"].intValue,
                releaseDay: JSON["release_day"].intValue,
                releaseNumber: JSON["release"].stringValue,
                description: JSON["description"].stringValue,
                genre: JSON["genre"].stringValue,
                type: PlaylistType(rawValue: JSON["playlist_type"].stringValue ?? ""),
                title: JSON["title"].stringValue ?? "",
                artworkURL: ImageURLs(baseURL: JSON["artwork_url"].urlValue),
                tracks: JSON["tracks"].flatMap { return Track(JSON: $0) } ?? [],
                ean: JSON["ean"].stringValue,
                sharingAccess: SharingAccess(rawValue: JSON["sharing"].stringValue ?? "") ?? .Private,
                labelIdentifier: JSON["label_id"].intValue,
                labelName: JSON["label_name"].stringValue,
                license: JSON["license"].stringValue)
        }
        else {
            return nil
        }
    }
}

////////////////////////////////////////////////////////////////////////////
