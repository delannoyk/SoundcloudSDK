//
//  Enums.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public enum SharingAccess: String {
    case `public` = "public"
    case `private` = "private"
}

public enum PlaylistType: String {
    case epSingle = "ep single"
    case album = "album"
    case compilation = "compilation"
    case projectFiles = "project files"
    case archive = "archive"
    case showcase = "showcase"
    case demo = "demo"
    case samplePack = "sample pack"
    case other = "other"
}
