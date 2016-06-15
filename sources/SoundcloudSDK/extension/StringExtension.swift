//
//  StringExtension.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 07/05/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

// MARK: - StringExtension
////////////////////////////////////////////////////////////////////////////

extension String: HTTPParametersConvertible {
    var queryStringValue: String {
        return self
    }

    var formDataValue: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding) ?? NSData()
    }
}

extension String {
    var queryDictionary: [String: String] {
        let parameters = componentsSeparatedByString("&")
        var dictionary = [String: String]()
        for parameter in parameters {
            let keyValue = parameter.componentsSeparatedByString("=")
            if keyValue.count == 2 {
                if let key = keyValue[0].stringByRemovingPercentEncoding,
                    value = keyValue[1].stringByRemovingPercentEncoding {
                        dictionary[key] = value
                }
            }
        }
        return dictionary
    }
}

////////////////////////////////////////////////////////////////////////////
