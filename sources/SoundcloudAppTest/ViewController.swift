//
//  ViewController.swift
//  SoundcloudAppTest
//
//  Created by Kevin DELANNOY on 18/07/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import UIKit
import Soundcloud

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet private weak var textFieldUserIdentifier: UITextField!
    @IBOutlet private weak var textFieldTrackIdentifier: UITextField!
    @IBOutlet private weak var textFieldSearchText: UITextField!

    var user: User?

    // MARK: IBAction

    @IBAction func buttonLoginPressed(_: AnyObject) {
        Soundcloud.login(in: self) { _ in }
    }

    @IBAction func buttonLoadMePressed(_: AnyObject) {
        Soundcloud.session?.me { [weak self] result in
            self?.user = result.response.result

            print(result.response.result)
            print(result.response.error)
        }
    }

    @IBAction func buttonFollowPressed(_: AnyObject) {
        user?.follow(userIdentifier: Int(textFieldUserIdentifier.text!)!) { result in
            print(result.response.result)
            print(result.response.error)

            self.user?.unfollow(userIdentifier: Int(self.textFieldUserIdentifier.text!)!) { result in
                print(result.response.result)
                print(result.response.error)
            }
        }
    }

    @IBAction func buttonFavoritePressed(_: AnyObject) {
        Track.track(identifier: Int(textFieldTrackIdentifier.text!)!) { result in
            result.response.result?.favorite { result in
                print(result.response.result)
                print(result.response.error)
            }
        }
    }

    @IBAction func buttonSearchPressed(_: AnyObject) {
        Track.search(queries: [.queryString(textFieldSearchText.text!)]) { result in
            print(result.response.result)
            print(result.response.error)
        }
    }


    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
