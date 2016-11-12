//
//  UserListViewController.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 2016-10-22.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

import UIKit
import Soundcloud

class UserListViewController: UIViewController {
    // MARK: Outlets

    @IBOutlet private weak var tableView: UITableView? {
        didSet {
            tableView?.estimatedRowHeight = 44
            tableView?.rowHeight = UITableViewAutomaticDimension
        }
    }

    // MARK: Properties

    var userResponse: PaginatedAPIResponse<User>? {
        didSet {
            users = userResponse?.response.result
            lastUserResponse = userResponse
        }
    }

    fileprivate var loading = false

    fileprivate var lastUserResponse: PaginatedAPIResponse<User>? {
        didSet {
            tableView?.reloadData()
        }
    }

    fileprivate var users: [User]?

    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "User" {
            (segue.destination as? UserViewController)?.user = sender as? User
        }
    }
}

// MARK: - UITableViewDelegate
extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == users?.count && !loading {
            loading = true

            //Now we have to unwrap the optional because of https://bugs.swift.org/browse/SR-1681
            guard let lastUserResponse = lastUserResponse else { return }
            lastUserResponse.fetchNextPage { [weak self] response in
                self?.loading = false

                if case .success(let users) = response.response {
                    self?.users?.append(contentsOf: users)
                }
                self?.lastUserResponse = response
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        performSegue(withIdentifier: "User", sender: users?[indexPath.row])
    }
}

// MARK: - UITableViewDataSource
extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (users?.count ?? 0) + (lastUserResponse?.hasNextPage == true ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == users?.count {
            return tableView.dequeueReusableCell(withIdentifier: "Loading", for: indexPath)
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "User", for: indexPath)
        if let cell = cell as? UserTableViewCell {
            cell.user = users?[indexPath.row]
        }
        return cell
    }
}
