//
//  UserTableViewCell.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 2016-10-23.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

import UIKit
import Soundcloud

class UserTableViewCell: UITableViewCell {
    @IBOutlet private weak var labelUsername: UILabel?
    @IBOutlet private weak var buttonFollow: UIButton?

    var user: User? {
        didSet {
            labelUsername?.text = user?.username
        }
    }
}
