//
//  Track.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public enum TrackType: String {
    case original = "original"
    case remix = "remix"
    case live = "live"
    case recording = "recording"
    case spoken = "spoken"
    case podcast = "podcast"
    case demo = "demo"
    case inProgress = "in progress"
    case stem = "stem"
    case loop = "loop"
    case soundEffect = "sound effect"
    case sample = "sample"
    case other = "other"
}

public struct Track {
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
    public let tags: [String]?

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

// MARK: Equatable

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

// MARK: Parsing

extension Track {
    init?(JSON: JSONObject) {
        guard let identifier = JSON["id"].intValue, let user = User(JSON: JSON["user"]) else {
            return nil
        }

        self.identifier = identifier
        self.createdAt = JSON["created_at"].dateValue(format: "yyyy/MM/dd HH:mm:ss VVVV") ?? Date()
        self.createdBy = user
        self.createdWith = App(JSON: JSON["created_with"])
        self.duration = JSON["duration"].doubleValue.map { $0 / 1000 } ?? 0
        self.commentable = JSON["commentable"].boolValue ?? false
        self.streamable = JSON["streamable"].boolValue ?? false
        self.downloadable = JSON["downloadable"].boolValue ?? false
        self.streamURL = JSON["stream_url"].urlValue
        self.downloadURL = JSON["download_url"].urlValue
        self.permalinkURL = JSON["permalink_url"].urlValue
        self.releaseYear = JSON["release_year"].intValue
        self.releaseMonth = JSON["release_month"].intValue
        self.releaseDay = JSON["release_day"].intValue
        self.tags = JSON["tag_list"].stringValue.map { [$0] }
        self.description = JSON["description"].stringValue
        self.genre = JSON["genre"].stringValue
        self.trackType = TrackType(rawValue: JSON["track_type"].stringValue ?? "")
        self.title = JSON["title"].stringValue ?? ""
        self.format = JSON["original_format"].stringValue
        self.contentSize = JSON["original_content_size"].intValue.map { UInt64($0) }
        self.artworkImageURL = ImageURLs(baseURL: JSON["artwork_url"].urlValue)
        self.waveformImageURL = ImageURLs(baseURL: JSON["waveform_url"].urlValue)
        self.playbackCount = JSON["playback_count"].intValue
        self.downloadCount = JSON["download_count"].intValue
        self.favoriteCount = JSON["favoritings_count"].intValue
        self.commentCount = JSON["comment_count"].intValue
        self.bpm = JSON["bpm"].intValue
    }
}
