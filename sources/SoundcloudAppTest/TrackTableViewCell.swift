//
//  TrackTableViewCell.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 2016-10-23.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

import UIKit
import Soundcloud

class TrackTableViewCell: UITableViewCell {
    @IBOutlet private weak var labelTitle: UILabel?
    @IBOutlet private weak var labelArtist: UILabel?

    var track: Track? {
        didSet {
            labelTitle?.text = track?.title
            labelArtist?.text = track?.createdBy.username
        }
    }
}
