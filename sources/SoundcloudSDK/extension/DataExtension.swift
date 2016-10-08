//
//  DataExtension.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 15/06/16.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

import Foundation

// MARK: - HTTPParametersConvertible

extension Data: HTTPParametersConvertible {
    //This is not supported
    var queryStringValue: String {
        return ""
    }

    var formDataValue: Data {
        return self
    }
}
