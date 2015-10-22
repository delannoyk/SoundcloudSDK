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
    ////////////////////////////////////////////////////////////////////////////

    @IBAction func buttonLoginPressed(_: AnyObject) {
        Session.login(self, completion: { result in
        })
    }

    @IBAction func buttonLoadMePressed(_: AnyObject) {
        Soundcloud.session?.me({ result in
            self.user = result.response.result

            if let user = result.response.result {
                print(user)
            }
        })
    }

    @IBAction func buttonFollowPressed(_: AnyObject) {
        user?.follow(Int(textFieldUserIdentifier.text!)!, completion: { result in
            print(result.response.result)
            print(result.response.error)

            self.user?.unfollow(Int(self.textFieldUserIdentifier.text!)!, completion: { result in
                print(result.response.result)
                print(result.response.error)
            })
        })
    }

    @IBAction func buttonFavoritePressed(_: AnyObject) {
        Track.track(Int(textFieldTrackIdentifier.text!)!, completion: { result in
            result.response.result?.favorite(self.user!.identifier, completion: { result in
                print(result.response.result)
                print(result.response.error)
            })
        })
    }

    @IBAction func buttonSearchPressed(_: AnyObject) {
        Track.search([.QueryString(textFieldSearchText.text!)], completion: { result in
            print(result.response.result)
            print(result.response.error)
        })
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: UITextFieldDelegate
    ////////////////////////////////////////////////////////////////////////////

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    ////////////////////////////////////////////////////////////////////////////
}

