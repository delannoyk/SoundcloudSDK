//
//  Soundcloud.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import UIKit
import UICKeyChainStore

// MARK: - Session
////////////////////////////////////////////////////////////////////////////

public class Session: NSObject, NSCoding, NSCopying {
    //First session info
    internal var authorizationCode: String

    //Token
    internal var accessToken: String?
    internal var accessTokenExpireDate: NSDate?
    internal var scope: String?

    //Future session
    internal var refreshToken: String?

    // MARK: Initialization
    ////////////////////////////////////////////////////////////////////////////

    internal init(authorizationCode: String) {
        self.authorizationCode = authorizationCode
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: NSCoding
    ////////////////////////////////////////////////////////////////////////////

    private static let authorizationCodeKey = "authorizationCodeKey"
    private static let accessTokenKey = "accessTokenKey"
    private static let accessTokenExpireDateKey = "accessTokenExpireDateKey"
    private static let scopeKey = "scopeKey"
    private static let refreshTokenKey = "refreshTokenKey"

    required public init(coder aDecoder: NSCoder) {
        authorizationCode = aDecoder.decodeObjectForKey(Session.authorizationCodeKey) as! String
        accessToken = aDecoder.decodeObjectForKey(Session.accessTokenKey) as? String
        accessTokenExpireDate = aDecoder.decodeObjectForKey(Session.accessTokenExpireDateKey) as? NSDate
        scope = aDecoder.decodeObjectForKey(Session.scopeKey) as? String
        refreshToken = aDecoder.decodeObjectForKey(Session.refreshTokenKey) as? String
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(authorizationCode, forKey: Session.authorizationCodeKey)
        aCoder.encodeObject(accessToken, forKey: Session.accessTokenKey)
        aCoder.encodeObject(accessTokenExpireDate, forKey: Session.accessTokenExpireDateKey)
        aCoder.encodeObject(scope, forKey: Session.scopeKey)
        aCoder.encodeObject(refreshToken, forKey: Session.refreshTokenKey)
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: NSCopying
    ////////////////////////////////////////////////////////////////////////////

    public func copyWithZone(zone: NSZone) -> AnyObject {
        let session = Session(authorizationCode: authorizationCode)
        session.accessToken = accessToken
        session.accessTokenExpireDate = accessTokenExpireDate
        session.scope = scope
        session.refreshToken = refreshToken
        return session
    }

    ////////////////////////////////////////////////////////////////////////////
}

extension Session {
    // MARK: Public methods
    ////////////////////////////////////////////////////////////////////////////

    /**
    Logs a user in. This method will present an UIViewController over `displayViewController`
    that will load a web view so that user is available to log in

    :param: displayViewController An UIViewController that is in the view hierarchy
    :param: completion            The closure that will be called when the user is logged in or upon error
    */
    public static func login(displayViewController: UIViewController, completion: Result<Session> -> Void) {
        authorize(displayViewController, completion: { result in
            if let session = result.result {
                session.getToken({ result in
                    Soundcloud.session = result.result
                    completion(result)
                })
            }
            else {
                completion(result)
            }
        })
    }

    /**
    Refresh the token of the logged user. You should call this method when you get a 401 error on
    API calls

    :param: completion The closure that will be called when the session is refreshed or upon error
    */
    public func refreshSession(completion: Result<Session> -> Void) {
        _refreshToken({ result in
            if let session = result.result {
                Soundcloud.session = session
            }
            completion(result)
        })
    }

    /**
    Logs out the current user. This is a straight-forward call.
    */
    public func destroy() {
        Soundcloud.session = nil
    }

    /**
    Fetch current user's profile.

    **This method requires a Session.**

    :param: completion The closure that will be called when the profile is loaded or upon error
    */
    public func me(completion: Result<User> -> Void) {
        if let clientId = Soundcloud.clientIdentifier, oauthToken = accessToken {
            let URL = NSURL(string: "https://api.soundcloud.com/me")!

            let parameters = [
                "client_id": clientId,
                "oauth_token": oauthToken,
            ]

            let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
                if let user = User(JSON: $0) {
                    return .Success(Box(user))
                }
                return .Failure(GenericError)
                }, completion: { result, response in
                    refreshTokenIfNecessaryCompletion(response, {
                        Soundcloud.session?.me(completion)
                        }, completion, result)
            })
            request.start()
        }
        else {
            completion(.Failure(GenericError))
        }
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Authorize
    ////////////////////////////////////////////////////////////////////////////

    internal static func authorize(displayViewController: UIViewController, completion: Result<Session> -> Void) {
        if let clientId = Soundcloud.clientIdentifier, redirectURI = Soundcloud.redirectURI {
            let URL = NSURL(string: "https://soundcloud.com/connect")!

            let parameters = [
                "client_id": clientId,
                "redirect_uri": redirectURI,
                "response_type": "code"
            ]

            let web = SoundcloudWebViewController()
            web.autoDismissScheme = NSURL(string: redirectURI)?.scheme
            web.URL = URL.URLByAppendingQueryString(parameters.queryString)
            web.navigationItem.title = "Soundcloud"
            web.onDismiss = { URL in
                if let accessCode = URL?.query?.queryDictionary["code"] {
                    let session = Session(authorizationCode: accessCode)
                    completion(.Success(Box(session)))
                }
                else {
                    completion(.Failure(GenericError))
                }
            }

            let nav = UINavigationController(rootViewController: web)
            displayViewController.presentViewController(nav, animated: true, completion: nil)
        }
        else {
            completion(.Failure(GenericError))
        }
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Token
    ////////////////////////////////////////////////////////////////////////////

    internal func getToken(completion: Result<Session> -> Void) {
        if let clientId = Soundcloud.clientIdentifier, clientSecret = Soundcloud.clientSecret, redirectURI = Soundcloud.redirectURI {
            let parameters = [
                "client_id": clientId,
                "client_secret": clientSecret,
                "redirect_uri": redirectURI,
                "grant_type": "authorization_code",
                "code": authorizationCode
            ]
            token(parameters, completion: completion)
        }
        else {
            completion(.Failure(GenericError))
        }
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Refresh Token
    ////////////////////////////////////////////////////////////////////////////

    internal func _refreshToken(completion: Result<Session> -> Void) {
        if let clientId = Soundcloud.clientIdentifier, clientSecret = Soundcloud.clientSecret, redirectURI = Soundcloud.redirectURI, refreshToken = refreshToken {
            let parameters = [
                "client_id": clientId,
                "client_secret": clientSecret,
                "redirect_uri": redirectURI,
                "grant_type": "refresh_token",
                "code": authorizationCode,
                "refresh_token": refreshToken
            ]
            token(parameters, completion: completion)
        }
        else {
            completion(.Failure(GenericError))
        }
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Token requests
    ////////////////////////////////////////////////////////////////////////////

    private func token(parameters: HTTPParametersConvertible, completion: Result<Session> -> Void) {
        let URL = NSURL(string: "https://api.soundcloud.com/oauth2/token")!

        let request = Request(URL: URL, method: .POST, parameters: parameters, parse: {
            if let accessToken = $0["access_token"].stringValue, expires = $0["expires_in"].doubleValue, scope = $0["scope"].stringValue {
                let newSession = self.copy() as! Session
                newSession.accessToken = accessToken
                newSession.accessTokenExpireDate = NSDate(timeIntervalSinceNow: expires)
                newSession.scope = scope
                newSession.refreshToken = $0["refresh_token"].stringValue
                return .Success(Box(newSession))
            }
            return .Failure(GenericError)
            }, completion: { result, response in
                completion(result)
        })
        request.start()
    }

    ////////////////////////////////////////////////////////////////////////////
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Soundcloud
////////////////////////////////////////////////////////////////////////////

public class Soundcloud: NSObject {
    // MARK: Properties
    ////////////////////////////////////////////////////////////////////////////

    private static let sessionKey = "sessionKey"

    private static let keychain = UICKeyChainStore(server: NSURL(string: "https://soundcloud.com")!,
        protocolType: .HTTPS)

    /// The session property is only set when a user has logged in.
    public private(set) static var session: Session? = {
        if let data = keychain.dataForKey(sessionKey), session = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Session {
            return session
        }
        return nil
    }() {
        didSet {
            if let session = session {
                let data = NSKeyedArchiver.archivedDataWithRootObject(session)
                keychain.setData(data, forKey: sessionKey)
            }
            else {
                keychain.removeItemForKey(sessionKey)
            }
        }
    }

    /// Your Soundcloud app client identifier
    public static var clientIdentifier: String?

    /// Your Soundcloud app client secret
    public static var clientSecret: String?

    /// Your Soundcloud redirect URI
    public static var redirectURI: String?

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Requests
    ////////////////////////////////////////////////////////////////////////////

    /// A resolve response can either be a/some User(s) or a/some Track(s) or a Playlist.
    public typealias ResolveResponse = (users: [User]?, tracks: [Track]?, playlist: Playlist?)

    /**
    Resolve allows you to lookup and access API resources when you only know the SoundCloud.com URL.

    :param: URI        The URI to lookup
    :param: completion The closure that will be called when the result is ready or upon error
    */
    public static func resolve(URI: String, completion: Result<ResolveResponse> -> Void) {
        if let clientId = clientIdentifier {
            let URL = NSURL(string: "http://api.soundcloud.com/resolve")!
            let parameters = ["client_id": clientId,
                "url": URI
            ]

            let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
                if let user = User(JSON: $0) {
                    return .Success(Box(ResolveResponse(users: [user], tracks: nil, playlist: nil)))
                }

                if let playlist = Playlist(JSON: $0) {
                    return .Success(Box(ResolveResponse(users: nil, tracks: nil, playlist: playlist)))
                }

                if let track = Track(JSON: $0) {
                    return .Success(Box(ResolveResponse(users: nil, tracks: [track], playlist: nil)))
                }

                let users = $0.map { return User(JSON: $0) }
                if let users = users where users.count > 0 {
                    return .Success(Box(ResolveResponse(users: compact(users), tracks: nil, playlist: nil)))
                }

                let tracks = $0.map { return Track(JSON: $0) }
                if let tracks = tracks where tracks.count > 0 {
                    return .Success(Box(ResolveResponse(users: nil, tracks: compact(tracks), playlist: nil)))
                }
                
                return .Failure(GenericError)
                }, completion: { result, response in
                    completion(result)
            })
            request.start()
        }
        else {
            completion(.Failure(GenericError))
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}

////////////////////////////////////////////////////////////////////////////
