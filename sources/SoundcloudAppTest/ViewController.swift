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
        Session.login(displayViewController: self, completion: { result in
            result.response.result?.me { user in
                print(user.response)
            }
        })
    }

    @IBAction func buttonLoadMePressed(_: AnyObject) {
        /*Soundcloud.session?.me({ result in
            self.user = result.response.result

            /*if let user = result.response.result {
                print(user)
            }*/
        })

        Soundcloud.session?.activities { result in
            print(result.response.result)
        }*/

        Playlist.create(withName: "Test SC de Test", sharingAccess: .Private) { response in
            print(response.response)
            Track.search(queries: [.genres(["punk"])]) { trackResult in
                print(trackResult.response)

                response.response.result?.addTrack(withIdentifier: trackResult.response.result!.first!.identifier) { add in
                    print(add.response)
                }
            }
        }
    }

    @IBAction func buttonFollowPressed(_: AnyObject) {
        user?.follow(userIdentifier: Int(textFieldUserIdentifier.text!)!, completion: { result in
            print(result.response.result)
            print(result.response.error)

            self.user?.unfollow(userIdentifier: Int(self.textFieldUserIdentifier.text!)!, completion: { result in
                print(result.response.result)
                print(result.response.error)
            })
        })
    }

    @IBAction func buttonFavoritePressed(_: AnyObject) {
        Track.track(identifier: Int(textFieldTrackIdentifier.text!)!, completion: { result in
            result.response.result?.favorite(userIdentifier: self.user!.identifier, completion: { result in
                print(result.response.result)
                print(result.response.error)
            })
        })
    }

    @IBAction func buttonSearchPressed(_: AnyObject) {
        Track.search(queries: [.queryString(textFieldSearchText.text!)], completion: { result in
            print(result.response.result)
            print(result.response.error)
        })
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: UITextFieldDelegate
    ////////////////////////////////////////////////////////////////////////////

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    ////////////////////////////////////////////////////////////////////////////
}

