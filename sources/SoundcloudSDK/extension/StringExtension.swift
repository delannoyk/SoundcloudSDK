//
//  StringExtension.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 07/05/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import UIKit

// MARK: - StringExtension
////////////////////////////////////////////////////////////////////////////

extension String: HTTPParametersConvertible {
    var stringValue: String {
        return self
    }

    var dataValue: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding) ?? NSData()
    }
}

////////////////////////////////////////////////////////////////////////////
