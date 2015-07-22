//
//  Comment.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import UIKit

// MARK: - Comment definition
////////////////////////////////////////////////////////////////////////////

public struct Comment {
    ///User's identifier
    public let identifier: Int

    ///Creation date of the track
    public let createdAt: NSDate

    ///Track's identifier
    public let trackIdentifier: Int?

    ///User's identifier
    public let userIdentifier: Int?

    ///Comment's timestamp
    public let timestamp: NSTimeInterval?

    ///Body
    public let body: String

    ///User
    public let user: User?
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Track Extensions
////////////////////////////////////////////////////////////////////////////

// MARK: Parsing
////////////////////////////////////////////////////////////////////////////

internal extension Comment {
    init?(JSON: JSONObject) {
        if let identifier = JSON["id"].intValue, body = JSON["body"].stringValue {
            self.identifier = identifier
            self.createdAt = JSON["created_at"].dateValue("yyyy/MM/dd HH:mm:ss VVVV") ?? NSDate()
            self.trackIdentifier = JSON["track_id"].intValue
            self.userIdentifier = JSON["user_id"].intValue
            self.timestamp = JSON["timestamp"].doubleValue
            self.body = body
            self.user = User(JSON: JSON["user"])
        }
        else {
            return nil
        }
    }
}

////////////////////////////////////////////////////////////////////////////


// MARK: Caching ease
////////////////////////////////////////////////////////////////////////////

public extension Comment {
    /**
    Returns NSData to ease caching of the struct.

    :returns: NSData representation of the struct.
    */
    public mutating func toData() -> NSData {
        return NSData(bytes: &self, length: sizeof(self.dynamicType))
    }

    internal static var empty: Comment {
        return Comment(identifier: 0,
            createdAt: NSDate(),
            trackIdentifier: nil,
            userIdentifier: nil,
            timestamp: nil,
            body: "",
            user: nil)
    }

    /**
    Initialize a new struct from NSData.

    :param: data NSData representation of the struct.

    :returns: An initialized struct.
    */
    public static func fromData(data: NSData) -> Comment {
        var comment = empty
        data.getBytes(&comment, length: sizeof(Comment))
        return comment
    }
}

////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
