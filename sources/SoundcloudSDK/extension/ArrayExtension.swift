//
//  ArrayExtension.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import UIKit

// MARK: Compact
////////////////////////////////////////////////////////////////////////////

internal func compact<T>(objects: [T?]?) -> [T] {
    if let objects = objects {
        return objects.reduce([]) { (list: [T], o: T?) in
            if let o = o {
                return list + [o]
            }
            return list
        }
    }
    return []
}

////////////////////////////////////////////////////////////////////////////
