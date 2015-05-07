//
//  DictionaryExtension.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import UIKit

// MARK: - StringExtension
////////////////////////////////////////////////////////////////////////////

private extension String {
    // MARK: URL Encoding
    ////////////////////////////////////////////////////////////////////////////

    var URLEncodedValue: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) ?? self
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
        let parts = map(self, {(key, value) -> String in
            let keyStr = "\(key)"
            let valueStr = "\(value)"
            return "\(keyStr.URLEncodedValue)=\(valueStr.URLEncodedValue)"
        })
        return join("&", parts)
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
