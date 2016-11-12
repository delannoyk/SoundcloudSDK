//
//  UserViewController.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 2016-10-22.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

import UIKit
import Soundcloud

class UserViewController: UIViewController {
    // MARK: Outlets

    @IBOutlet private var labelFollowersCount: UILabel?
    @IBOutlet private var labelFollowingsCount: UILabel?
    @IBOutlet private var activityIndicator: UIActivityIndicatorView?

    // MARK: Properties

    private var trackListViewController: TrackListViewController? {
        didSet {
            updateTracks()
        }
    }

    private var trackResponse: PaginatedAPIResponse<Track>? {
        didSet {
            updateTracks()
        }
    }

    private func updateTracks() {
        trackListViewController?.trackResponse = trackResponse
    }

    var user: User? {
        didSet {
            updateUser()
        }
    }

    private func updateUser() {
        labelFollowersCount?.text = user.map { String($0.followersCount) }
        labelFollowingsCount?.text = user.map { String($0.followingsCount) }

        title = user?.username

        trackResponse = nil
        activityIndicator?.startAnimating()

        //Now we have to unwrap the optional because of https://bugs.swift.org/browse/SR-1681
        guard let user = user else { return }
        user.tracks { [weak self] response in
            self?.activityIndicator?.stopAnimating()

            switch response.response {
            case .success:
                self?.trackResponse = response
            case .failure(let error):
                dump(error)
            }
        }
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUser()
    }

    // MARK: Segue

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let user = user else { return false }
        if identifier == "Followers" {
            return user.followersCount > 0
        }
        if identifier == "Followings" {
            return user.followingsCount > 0
        }
        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "Tracks" {
            trackListViewController = segue.destination as? TrackListViewController
        } else if segue.identifier == "Followers" {
            //Now we have to unwrap the optional because of https://bugs.swift.org/browse/SR-1681
            guard let user = user else { return }
            user.followers { response in
                (segue.destination as? UserListViewController)?.userResponse = response
            }
        } else if segue.identifier == "Followings" {
            //Now we have to unwrap the optional because of https://bugs.swift.org/browse/SR-1681
            guard let user = user else { return }
            user.followings { response in
                (segue.destination as? UserListViewController)?.userResponse = response
            }
        }
    }
}
