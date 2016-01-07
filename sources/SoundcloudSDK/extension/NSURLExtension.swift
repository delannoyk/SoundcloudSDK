//
//  NSURLExtension.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

// MARK: - NSURLExtension
////////////////////////////////////////////////////////////////////////////

internal extension NSURL {
    // MARK: Adding parameters
    ////////////////////////////////////////////////////////////////////////////

    func URLByAppendingQueryString(queryString: String) -> NSURL {
        if !queryString.isEmpty {
            let delimiter = (self.query == nil ? "?" : "&")
            let URLString = "\(self.absoluteString)\(delimiter)\(queryString)"
            if let URL = NSURL(string: URLString) {
                return URL
            }
        }
        return self
    }

    ////////////////////////////////////////////////////////////////////////////
}

////////////////////////////////////////////////////////////////////////////
