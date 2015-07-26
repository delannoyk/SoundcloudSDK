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

    @IBAction func buttonLoginPressed(AnyObject) {
        Session.login(self, completion: { result in
        })
    }

    @IBAction func buttonLoadMePressed(AnyObject) {
        Soundcloud.session?.me({ result in
            self.user = result.result

            if let user = result.result {
                println(user)
            }
        })
    }

    @IBAction func buttonFollowPressed(AnyObject) {
        user?.follow(textFieldUserIdentifier.text.toInt()!, completion: { result in
            println(result.result)
            println(result.error)

            self.user?.unfollow(self.textFieldUserIdentifier.text.toInt()!, completion: { result in
                println(result.result)
                println(result.error)
            })
        })
    }

    @IBAction func buttonFavoritePressed(AnyObject) {
        Track.track(textFieldTrackIdentifier.text.toInt()!, completion: { result in
            result.result?.favorite(self.user!.identifier, completion: { result in
                println(result.result)
                println(result.error)
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

