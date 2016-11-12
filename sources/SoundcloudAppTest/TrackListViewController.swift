//
//  TrackListViewController.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 2016-10-22.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

import UIKit
import Soundcloud

class TrackListViewController: UIViewController {
    // MARK: Outlets

    @IBOutlet private weak var tableView: UITableView? {
        didSet {
            tableView?.estimatedRowHeight = 44
            tableView?.rowHeight = UITableViewAutomaticDimension
        }
    }

    // MARK: Properties

    var trackResponse: PaginatedAPIResponse<Track>? {
        didSet {
            tracks = trackResponse?.response.result
            lastTrackResponse = trackResponse
        }
    }

    fileprivate var loading = false

    fileprivate var lastTrackResponse: PaginatedAPIResponse<Track>? {
        didSet {
            tableView?.reloadData()
        }
    }

    fileprivate var tracks: [Track]?
}

// MARK: - UITableViewDelegate
extension TrackListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tracks?.count && !loading {
            loading = true

            //Now we have to unwrap the optional because of https://bugs.swift.org/browse/SR-1681
            guard let lastTrackResponse = lastTrackResponse else { return }
            lastTrackResponse.fetchNextPage { [weak self] response in
                self?.loading = false

                if case .success(let tracks) = response.response {
                    self?.tracks?.append(contentsOf: tracks)
                }
                self?.lastTrackResponse = response
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension TrackListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tracks?.count ?? 0) + (lastTrackResponse?.hasNextPage == true ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == tracks?.count {
            return tableView.dequeueReusableCell(withIdentifier: "Loading", for: indexPath)
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "Track", for: indexPath)
        if let cell = cell as? TrackTableViewCell {
            cell.track = tracks?[indexPath.row]
        }
        return cell
    }
}
