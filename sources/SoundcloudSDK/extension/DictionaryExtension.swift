//
//  DictionaryExtension.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

// MARK: - StringExtension
////////////////////////////////////////////////////////////////////////////

internal extension String {
    // MARK: URL Encoding
    ////////////////////////////////////////////////////////////////////////////

    var URLEncodedValue: String {
        let customAllowedSet =  NSCharacterSet(charactersInString: "=\"#%/<>?@\\^`{|}&: ").invertedSet
        let escapedString = stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)
        return escapedString ?? self
    }

    ////////////////////////////////////////////////////////////////////////////
}

////////////////////////////////////////////////////////////////////////////


// MARK: - DictionaryExtension
////////////////////////////////////////////////////////////////////////////

internal extension Dictionary {
    // MARK: Query string
    ////////////////////////////////////////////////////////////////////////////

    var queryString: String {
        let parts = map({(key, value) -> String in
            let keyStr = "\(key)"
            let valueStr = "\(value)"
            return "\(keyStr)=\(valueStr.URLEncodedValue)"
        })
        return parts.joinWithSeparator("&")
    }

    ////////////////////////////////////////////////////////////////////////////
}

extension Dictionary: HTTPParametersConvertible {
    var stringValue: String {
        return queryString
    }

    var dataValue: NSData {
        return queryString.dataUsingEncoding(NSUTF8StringEncoding) ?? NSData()
    }
}

////////////////////////////////////////////////////////////////////////////
