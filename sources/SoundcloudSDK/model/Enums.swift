//
//  Enums.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public enum SharingAccess: String {
    case Public = "public"
    case Private = "private"
}

public enum PlaylistType: String {
    case EPSingle = "ep single"
    case Album = "album"
    case Compilation = "compilation"
    case ProjectFiles = "project files"
    case Archive = "archive"
    case Showcase = "showcase"
    case Demo = "demo"
    case SamplePack = "sample pack"
    case Other = "other"
}
