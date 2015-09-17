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

    var user: User?

    // MARK: IBAction
    ////////////////////////////////////////////////////////////////////////////

    @IBAction func buttonLoginPressed(_: AnyObject) {
        Session.login(self, completion: { result in
        })
    }

    @IBAction func buttonLoadMePressed(_: AnyObject) {
        Soundcloud.session?.me({ result in
            self.user = result.result

            if let user = result.result {
                print(user)
            }
        })
    }

    @IBAction func buttonFollowPressed(_: AnyObject) {
        user?.follow(Int(textFieldUserIdentifier.text!)!, completion: { result in
            print(result.result)
            print(result.error)

            self.user?.unfollow(Int(self.textFieldUserIdentifier.text!)!, completion: { result in
                print(result.result)
                print(result.error)
            })
        })
    }

    @IBAction func buttonFavoritePressed(_: AnyObject) {
        Track.track(Int(textFieldTrackIdentifier.text!)!, completion: { result in
            result.result?.favorite(self.user!.identifier, completion: { result in
                print(result.result)
                print(result.error)
            })
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

