//
//  Playlist.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation
/*
// MARK: - Playlist's definition
////////////////////////////////////////////////////////////////////////////

public struct Playlist {
    ///Playlist's identifier
    public let identifier: Int

    ///API resource URL
    public let URL: NSURL

    ///URL to the SoundCloud.com page
    public let permalinkURL: NSURL

    ///Date of creation
    public let creationDate: NSDate

    ///Duration
    public let duration: NSTimeInterval

    ///public/private sharing
    public let sharingAccess: SharingAccess

    ///Mini user representation of the owner
    public let user: User

    ///Tracks
    public let tracks: [Track]

    ///Permalink of the resource
    public let permalink: String

    ///Streamable via API (This will aggregate the playlists tracks streamable attribute. Its value will be nil if not all tracks have the same streamable value.)
    public let streamable: Bool?

    ///Downloadable (This will aggregate the playlists tracks downloadable attribute. Its value will be nil if not all tracks have the same downloadable value.)
    public let downloadable: Bool?

    ///Who can embed this track or playlist
    public let embeddableBy: EmbeddablePermission

    ///External purchase link
    public let purchaseURL: NSURL?

    ///Identifier of the label user
    public let labelIdentifier: Int

    ///EAN identifier for the playlist
    public let ean: String

    ///HTML description
    public let description: String

    ///Genre
    public let genre: String

    ///Release number
    public let releaseNumber: String

    ///Purchase title
    public let purchaseTitle: String?

    ///Label name
    public let labelName: String

    ///Track title
    public let title: String

    ///Release date
    public let releaseDate: NSDate

    ///Creative common license
    public let license: String

    ///URL to a JPEG image
    public let artworkURL: NSURL

    ///Playlist type
    public let type: PlaylistType
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Equatable
////////////////////////////////////////////////////////////////////////////

extension Playlist: Equatable {}

/**
Compares 2 Playlists based on their identifier

:param: lhs First playlist
:param: rhs Second playlist

:returns: true if playlists are equals, false if they're not
*/
public func ==(lhs: Playlist, rhs: Playlist) -> Bool {
    return lhs.identifier == rhs.identifier
}

////////////////////////////////////////////////////////////////////////////
*/