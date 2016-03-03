//
//  Activity.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 03/03/16.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

import Foundation

public enum Activity {
    case TrackActivity(Track)
    case TrackSharing(Track)
    case PlaylistActivity(Playlist)
}

extension Activity {
    init?(JSON: JSONObject) {
        guard let type = JSON["type"].stringValue else {
            return nil
        }

        switch type {
        case "track":
            guard let track = Track(JSON: JSON["origin"]) else {
                return nil
            }
            self = .TrackActivity(track)

        case "track-sharing", "track-repost":
            guard let track = Track(JSON: JSON["origin"]) else {
                return nil
            }
            self = .TrackSharing(track)

        case "playlist":
            guard let playlist = Playlist(JSON: JSON["origin"]) else {
                return nil
            }
            self = .PlaylistActivity(playlist)

        default:
            return nil
        }
    }
}
