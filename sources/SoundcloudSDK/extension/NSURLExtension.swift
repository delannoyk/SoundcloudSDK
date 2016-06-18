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

extension URL {
    // MARK: Adding parameters
    ////////////////////////////////////////////////////////////////////////////

    func appendingQueryString(_ queryString: String) -> URL {
        if !queryString.isEmpty {
            let delimiter = (self.query == nil ? "?" : "&")
            let URLString = "\(self.absoluteString)\(delimiter)\(queryString)"
            if let URL = URL(string: URLString) {
                return URL
            }
        }
        return self
    }

    ////////////////////////////////////////////////////////////////////////////
}

////////////////////////////////////////////////////////////////////////////
