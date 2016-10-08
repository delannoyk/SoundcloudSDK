//
//  StringExtension.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 07/05/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

// MARK: - HTTPParametersConvertible
extension String: HTTPParametersConvertible {
    var queryStringValue: String {
        return self
    }

    var formDataValue: Data {
        return data(using: .utf8) ?? Data()
    }
}

// MARK: - Query dictionary
extension String {
    var queryDictionary: [String: String] {
        let parameters = components(separatedBy: "&")
        var dictionary = [String: String]()
        for parameter in parameters {
            let keyValue = parameter.components(separatedBy: "=")
            if keyValue.count == 2,
                let key = keyValue[0].removingPercentEncoding,
                let value = keyValue[1].removingPercentEncoding {
                    dictionary[key] = value
            }
        }
        return dictionary
    }
}
