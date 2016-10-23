//
//  SearchViewController.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 2016-10-22.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

import UIKit
import Soundcloud

class SearchViewController: UIViewController {
    //MARK: Outlets

    @IBOutlet fileprivate weak var textFieldContent: UITextField?
    @IBOutlet fileprivate weak var buttonSearch: UIButton?
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView?

    // MARK: Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshSessionButton()
    }

    // MARK: Session

    fileprivate func refreshSessionButton() {
        if let _ = Soundcloud.session {
            navigationItem.rightBarButtonItem?.title = "My Profile"
        } else {
            navigationItem.rightBarButtonItem?.title = "Login"
        }
    }

    // MARK: Search

    fileprivate func search(for content: String) {
        guard !content.isEmpty else { return }

        textFieldContent?.isEnabled = false
        buttonSearch?.isEnabled = false
        activityIndicator?.startAnimating()

        Track.search(queries: [.queryString(content)]) { [weak self] response in
            self?.textFieldContent?.isEnabled = true
            self?.buttonSearch?.isEnabled = true
            self?.activityIndicator?.stopAnimating()

            if case .failure(let error) = response.response {
                dump(error)
            } else {
                self?.performSegue(withIdentifier: "Tracks", sender: response)
            }
        }
    }

    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "Profile" {
            (segue.destination as? UserViewController)?.user = sender as? User
        } else if segue.identifier == "Tracks" {
            (segue.destination as? TrackListViewController)?.trackResponse = sender as? PaginatedAPIResponse<Track>
            segue.destination.title = textFieldContent?.text
        }
    }
}

// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if let searchContent = textField.text {
            search(for: searchContent)
        }

        return false
    }
}

// MARK: - Actions
extension SearchViewController {
    @IBAction private func buttonSearchPressed(_: AnyObject) {
        textFieldContent?.resignFirstResponder()

        if let searchContent = textFieldContent?.text {
            search(for: searchContent)
        }
    }

    @IBAction private func tapGestureRecognizedOnView(_: AnyObject) {
        textFieldContent?.resignFirstResponder()
    }

    @IBAction private func rightBarButtonItemPressed(_: AnyObject) {
        if let session = Soundcloud.session {
            textFieldContent?.isEnabled = false
            buttonSearch?.isEnabled = false
            activityIndicator?.startAnimating()

            session.me { [weak self] response in
                self?.textFieldContent?.isEnabled = true
                self?.buttonSearch?.isEnabled = true
                self?.activityIndicator?.stopAnimating()

                switch response.response {
                case .success(let user):
                    self?.performSegue(withIdentifier: "Profile", sender: user)
                case .failure(let error):
                    dump(error)
                }
            }
        } else {
            Soundcloud.login(in: self) { [weak self] response in
                self?.refreshSessionButton()
            }
        }
    }
}
