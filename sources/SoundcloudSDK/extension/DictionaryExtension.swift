//
//  DictionaryExtension.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

// MARK: - URL Encoding

extension String {
    var urlEncodedValue: String {
        let allowedSet = CharacterSet(charactersIn: "=\"#%/<>?@\\^`{|}&: ").inverted
        let escapedString = addingPercentEncoding(withAllowedCharacters: allowedSet)
        return escapedString ?? self
    }
}

// MARK: - Query String

extension Dictionary {
    var queryString: String {
        let parts = map { (key, value) -> String in
            let keyStr = "\(key)"
            let valueStr = "\(value)"
            return "\(keyStr)=\(valueStr.urlEncodedValue)"
        }
        return parts.joined(separator: "&")
    }
}

// MARK: - HTTPParametersConvertible

extension Dictionary: HTTPParametersConvertible {
    var queryStringValue: String {
        return queryString
    }

    var formDataValue: Data {
        return queryString.data(using: .utf8) ?? Data()
    }
}
