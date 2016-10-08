//
//  Comment.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public struct Comment {
    ///User's identifier
    public let identifier: Int

    ///Creation date of the track
    public let createdAt: Date

    ///Track's identifier
    public let trackIdentifier: Int?

    ///User's identifier
    public let userIdentifier: Int?

    ///Comment's timestamp
    public let timestamp: TimeInterval?

    ///Body
    public let body: String

    ///User
    public let user: User?
}

// MARK: Equatable

extension Comment: Equatable {}

/**
 Compares 2 Comments based on their identifier

 - parameter lhs: First comment
 - parameter rhs: Second comment

 - returns: true if comments are equals, false if they're not
 */
public func ==(lhs: Comment, rhs: Comment) -> Bool {
    return lhs.identifier == rhs.identifier
}

// MARK: Parsing

extension Comment {
    init?(JSON: JSONObject) {
        guard let identifier = JSON["id"].intValue, let body = JSON["body"].stringValue else {
            return nil
        }

        self.identifier = identifier
        self.createdAt = JSON["created_at"].dateValue(format: "yyyy/MM/dd HH:mm:ss VVVV") ?? Date()
        self.trackIdentifier = JSON["track_id"].intValue
        self.userIdentifier = JSON["user_id"].intValue
        self.timestamp = JSON["timestamp"].doubleValue.map { $0 / 1000 }
        self.body = body
        self.user = User(JSON: JSON["user"])
    }
}
