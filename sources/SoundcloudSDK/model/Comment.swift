//
//  Comment.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

// MARK: - Comment definition
////////////////////////////////////////////////////////////////////////////

public struct Comment {
    public init(identifier: Int,
        createdAt: Date,
        trackIdentifier: Int?,
        userIdentifier: Int?,
        timestamp: TimeInterval?,
        body: String,
        user: User?) {
            self.identifier = identifier
            self.createdAt = createdAt
            self.trackIdentifier = trackIdentifier
            self.userIdentifier = userIdentifier
            self.timestamp = timestamp
            self.body = body
            self.user = user
    }

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

////////////////////////////////////////////////////////////////////////////


// MARK: - Comment Extensions
////////////////////////////////////////////////////////////////////////////

// MARK: Equatable
////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////


// MARK: Parsing
////////////////////////////////////////////////////////////////////////////

extension Comment {
    init?(JSON: JSONObject) {
        if let identifier = JSON["id"].intValue, let body = JSON["body"].stringValue {
            self.identifier = identifier
            self.createdAt = JSON["created_at"].dateValue(withFormat: "yyyy/MM/dd HH:mm:ss VVVV") ?? Date()
            self.trackIdentifier = JSON["track_id"].intValue
            self.userIdentifier = JSON["user_id"].intValue
            self.timestamp = JSON["timestamp"].doubleValue.map { $0 / 1000 }
            self.body = body
            self.user = User(JSON: JSON["user"])
        } else {
            return nil
        }
    }
}

////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
