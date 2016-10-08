//
//  URLExtension.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

// MARK: - Query String
extension URL {
    func appendingQueryString(_ queryString: String) -> URL {
        if !queryString.isEmpty {
            let delimiter = (query == nil ? "?" : "&")
            let urlString = "\(absoluteString)\(delimiter)\(queryString)"
            if let url = URL(string: urlString) {
                return url
            }
        }
        return self
    }
}
