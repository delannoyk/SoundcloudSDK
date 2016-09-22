//
//  Track.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

// MARK: - TrackType
////////////////////////////////////////////////////////////////////////////

public enum TrackType: String {
    case Original = "original"
    case Remix = "remix"
    case Live = "live"
    case Recording = "recording"
    case Spoken = "spoken"
    case Podcast = "podcast"
    case Demo = "demo"
    case InProgress = "in progress"
    case Stem = "stem"
    case Loop = "loop"
    case SoundEffect = "sound effect"
    case Sample = "sample"
    case Other = "other"
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Track definition
////////////////////////////////////////////////////////////////////////////

public struct Track {
    public init(identifier: Int, createdAt: Date, createdBy: User,
        createdWith: App?, duration: TimeInterval, commentable: Bool,
        streamable: Bool, downloadable: Bool, streamURL: URL?,
        downloadURL: URL?, permalinkURL: URL?,
        releaseYear: Int?, releaseMonth: Int?, releaseDay: Int?,
        tags: [String]?, description: String?, genre: String?,
        trackType: TrackType?, title: String, format: String?,
        contentSize: UInt64?, artworkImageURL: ImageURLs, waveformImageURL: ImageURLs,
        playbackCount: Int?, downloadCount: Int?, favoriteCount: Int?, commentCount: Int?, bpm: Int?) {
            self.identifier = identifier

            self.createdAt = createdAt
            self.createdBy = createdBy
            self.createdWith = createdWith

            self.duration = duration

            self.commentable = commentable
            self.streamable = streamable
            self.downloadable = downloadable

            self.streamURL = streamURL
            self.downloadURL = downloadURL
            self.permalinkURL = permalinkURL

            self.releaseYear = releaseYear
            self.releaseMonth = releaseMonth
            self.releaseDay = releaseDay

            self.tags = tags

            self.description = description
            self.genre = genre
            self.trackType = trackType
            self.title = title
            self.format = format
            self.contentSize = contentSize

            self.artworkImageURL = artworkImageURL
            self.waveformImageURL = waveformImageURL

            self.playbackCount = playbackCount
            self.downloadCount = downloadCount
            self.favoriteCount = favoriteCount
            self.commentCount = commentCount
            self.bpm = bpm
    }

    ///Track's identifier
    public let identifier: Int


    ///Creation date of the track
    public let createdAt: Date

    ///User that created the track (not a full user)
    public let createdBy: User

    ///App used to create the track
    public let createdWith: App?


    ///Track duration
    public let duration: TimeInterval


    ///Is commentable
    public let commentable: Bool

    ///Is streamable
    public let streamable: Bool

    ///Is downloadable
    public let downloadable: Bool


    ///Streaming URL
    public let streamURL: URL?

    ///Downloading URL
    public let downloadURL: URL?

    ///Permalink URL (website)
    public let permalinkURL: URL?


    ///Release year
    public let releaseYear: Int?
    
    // BPM
    public let bpm: Int?

    ///Release month
    public let releaseMonth: Int?

    ///Release day
    public let releaseDay: Int?


    ///Tags
    public let tags: [String]? /// "tag_list": "soundcloud:source=iphone-record",

    ///Track's description
    public let description: String?

    ///Genre
    public let genre: String?

    ///Type of the track
    public let trackType: TrackType?

    ///Track title
    public let title: String

    ///File format (m4a, mp3, ...)
    public let format: String?

    ///File size (in bytes)
    public let contentSize: UInt64?


    ///Image URL to artwork
    public let artworkImageURL: ImageURLs

    ///Image URL to waveform
    public let waveformImageURL: ImageURLs


    ///Playback count
    public let playbackCount: Int?

    ///Download count
    public let downloadCount: Int?

    ///Favorite count
    public let favoriteCount: Int?

    ///Comment count
    public let commentCount: Int?
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Track Extensions
////////////////////////////////////////////////////////////////////////////

// MARK: Equatable
////////////////////////////////////////////////////////////////////////////

extension Track: Equatable {}

/**
 Compares 2 Tracks based on their identifier

 - parameter lhs: First track
 - parameter rhs: Second track

 - returns: true if tracks are equals, false if they're not
 */
public func ==(lhs: Track, rhs: Track) -> Bool {
    return lhs.identifier == rhs.identifier
}

////////////////////////////////////////////////////////////////////////////


// MARK: Parsing
////////////////////////////////////////////////////////////////////////////

extension Track {
    init?(JSON: JSONObject) {
        if let identifier = JSON["id"].intValue, let user = User(JSON: JSON["user"]) {
            self.init(
                identifier: identifier,
                createdAt: JSON["created_at"].dateValue(withFormat: "yyyy/MM/dd HH:mm:ss VVVV") ?? Date(),
                createdBy: user,
                createdWith: App(JSON: JSON["created_with"]),
                duration: JSON["duration"].doubleValue.map { $0 / 1000 } ?? 0,
                commentable: JSON["commentable"].boolValue ?? false,
                streamable: JSON["streamable"].boolValue ?? false,
                downloadable: JSON["downloadable"].boolValue ?? false,
                streamURL: JSON["stream_url"].urlValue,
                downloadURL: JSON["download_url"].urlValue,
                permalinkURL: JSON["permalink_url"].urlValue,
                releaseYear: JSON["release_year"].intValue,
                releaseMonth: JSON["release_month"].intValue,
                releaseDay: JSON["release_day"].intValue,
                tags: JSON["tag_list"].stringValue.map { return [$0] }, //TODO: check this
                description: JSON["description"].stringValue,
                genre: JSON["genre"].stringValue,
                trackType: TrackType(rawValue: JSON["track_type"].stringValue ?? ""),
                title: JSON["title"].stringValue ?? "",
                format: JSON["original_format"].stringValue,
                contentSize: JSON["original_content_size"].intValue.map { UInt64($0) },
                artworkImageURL: ImageURLs(baseURL: JSON["artwork_url"].urlValue),
                waveformImageURL: ImageURLs(baseURL: JSON["waveform_url"].urlValue),
                playbackCount: JSON["playback_count"].intValue,
                downloadCount: JSON["download_count"].intValue,
                favoriteCount: JSON["favoritings_count"].intValue,
                commentCount: JSON["comment_count"].intValue,
                bpm: JSON["bpm"].intValue
            )
        }
        else {
            return nil
        }
    }
}

////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
