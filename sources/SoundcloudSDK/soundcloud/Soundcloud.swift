//
//  Soundcloud.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation
#if os(iOS) || os(OSX)
    import UICKeyChainStore
#endif

// MARK: - Errors
////////////////////////////////////////////////////////////////////////////

public enum SoundcloudError: ErrorType {
    case CredentialsNotSet
    case NotFound
    case Forbidden
    case Parsing
    case Unknown
    case Network(ErrorType)
    #if os(iOS) || os(OSX)
    case NeedsLogin
    #endif
}

extension SoundcloudError: RequestError {
    internal init(networkError: ErrorType) {
        self = .Network(networkError)
    }

    internal init(jsonError: ErrorType) {
        self = .Parsing
    }

    internal init?(httpURLResponse: NSHTTPURLResponse) {
        switch httpURLResponse.statusCode {
        case 200, 201:
            return nil
        case 401:
            self = .Forbidden
        case 404:
            self = .NotFound
        default:
            self = .Unknown
        }
    }
}

extension SoundcloudError: Equatable { }

public func ==(lhs: SoundcloudError, rhs: SoundcloudError) -> Bool {
    switch (lhs, rhs) {
    case (.CredentialsNotSet, .CredentialsNotSet):
        return true
    case (.NotFound, .NotFound):
        return true
    case (.Forbidden, .Forbidden):
        return true
    case (.Parsing, .Parsing):
        return true
    case (.Unknown, .Unknown):
        return true
    case (.Network(let e1), .Network(let e2)):
        return e1 as NSError == e2 as NSError
    default:
        //TODO: find a better way to express this
        #if os(iOS) || os(OSX)
            switch (lhs, rhs) {
            case (.NeedsLogin, .NeedsLogin):
                return true
            default:
                return false
            }
        #else
            return false
        #endif
    }
}

extension PaginatedAPIResponse {
    internal init(_ error: SoundcloudError) {
        self.init(response: .Failure(error), nextPageURL: nil) { _ in
            return .Failure(error)
        }
    }

    internal init(_ JSON: JSONObject, parse: JSONObject -> Result<[T], SoundcloudError>) {
        self.init(response: parse(JSON["collection"]), nextPageURL: JSON["next_href"].urlValue, parse: parse)
    }
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Session
////////////////////////////////////////////////////////////////////////////

#if os(iOS) || os(OSX)
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

    required public init?(coder aDecoder: NSCoder) {
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

    - parameter displayViewController: An UIViewController that is in the view hierarchy
    - parameter completion:            The closure that will be called when the user is logged in or upon error
    */
    public static func login(displayViewController: ViewController, completion: SimpleAPIResponse<Session> -> Void) {
        authorize(displayViewController, completion: { result in
            if let session = result.response.result {
                session.getToken({ result in
                    Soundcloud.session = result.response.result
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

    - parameter completion: The closure that will be called when the session is refreshed or upon error
    */
    public func refreshSession(completion: SimpleAPIResponse<Session> -> Void) {
        _refreshToken({ result in
            if let session = result.response.result {
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

    - parameter completion: The closure that will be called when the profile is loaded or upon error
    */
    public func me(completion: SimpleAPIResponse<User> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }

        guard let oauthToken = accessToken else {
            completion(SimpleAPIResponse(.NeedsLogin))
            return
        }

        let URL = NSURL(string: "https://api.soundcloud.com/me")!
        let parameters = ["client_id": clientIdentifier, "oauth_token": oauthToken]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            if let user = User(JSON: $0) {
                return .Success(user)
            }
            return .Failure(.Parsing)
            }) { result in
                completion(SimpleAPIResponse(result))
        }
        request.start()
    }

    /**
     Fetch current user's profile.

     **This method requires a Session.**

     - parameter completion: The closure that will be called when the activities are loaded or upon error
     */
    public func activities(completion: PaginatedAPIResponse<Activity> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(PaginatedAPIResponse(.CredentialsNotSet))
            return
        }

        guard let oauthToken = accessToken else {
            completion(PaginatedAPIResponse(.NeedsLogin))
            return
        }

        let URL = NSURL(string: "https://api.soundcloud.com/me/activities")!
        let parameters = ["client_id": clientIdentifier, "oauth_token": oauthToken, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[Activity], SoundcloudError> in
            guard let activities = JSON.flatMap({ return Activity(JSON: $0) }) else {
                return .Failure(.Parsing)
            }
            return .Success(activities)
        }

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Activity>, SoundcloudError> in
            return .Success(PaginatedAPIResponse(JSON, parse: parse))
            }) { result in
                completion(result.result!)
        }
        request.start()
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Authorize
    ////////////////////////////////////////////////////////////////////////////

    internal static func authorize(displayViewController: ViewController, completion: SimpleAPIResponse<Session> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier, redirectURI = Soundcloud.redirectURI else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }

        let url = NSURL(string: "https://soundcloud.com/connect")!

        let parameters = ["client_id": clientIdentifier,
            "redirect_uri": redirectURI,
            "response_type": "code"]

        let web = SoundcloudWebViewController()
        web.autoDismissScheme = NSURL(string: redirectURI)?.scheme
        web.url = url.URLByAppendingQueryString(parameters.queryString)
        web.onDismiss = { url in
            if let accessCode = url?.query?.queryDictionary["code"] {
                let session = Session(authorizationCode: accessCode)
                completion(SimpleAPIResponse(session))
            }
            else {
                completion(SimpleAPIResponse(.NeedsLogin))
            }
        }

        #if os(OSX)
            web.title = "Soundcloud"
            web.preferredContentSize = displayViewController.view.bounds.size

            displayViewController.presentViewControllerAsSheet(web)
        #else
            web.navigationItem.title = "Soundcloud"

            let nav = UINavigationController(rootViewController: web)
            displayViewController.presentViewController(nav, animated: true, completion: nil)
        #endif
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Token
    ////////////////////////////////////////////////////////////////////////////

    internal func getToken(completion: SimpleAPIResponse<Session> -> Void) {
        guard let clientId = Soundcloud.clientIdentifier, clientSecret = Soundcloud.clientSecret, redirectURI = Soundcloud.redirectURI else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }

        let parameters = ["client_id": clientId, "client_secret": clientSecret, "redirect_uri": redirectURI,
            "grant_type": "authorization_code", "code": authorizationCode]
        token(parameters, completion: completion)
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Refresh Token
    ////////////////////////////////////////////////////////////////////////////

    internal func _refreshToken(completion: SimpleAPIResponse<Session> -> Void) {
        guard let clientId = Soundcloud.clientIdentifier, clientSecret = Soundcloud.clientSecret, redirectURI = Soundcloud.redirectURI else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }

        guard let refreshToken = refreshToken else {
            completion(SimpleAPIResponse(.NeedsLogin))
            return
        }

        let parameters = ["client_id": clientId, "client_secret": clientSecret, "redirect_uri": redirectURI,
            "grant_type": "refresh_token", "code": authorizationCode, "refresh_token": refreshToken]
        token(parameters, completion: completion)
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Token requests
    ////////////////////////////////////////////////////////////////////////////

    private func token(parameters: HTTPParametersConvertible, completion: SimpleAPIResponse<Session> -> Void) {
        let URL = NSURL(string: "https://api.soundcloud.com/oauth2/token")!

        let request = Request(URL: URL, method: .POST, parameters: parameters, parse: {
            if let accessToken = $0["access_token"].stringValue, expires = $0["expires_in"].doubleValue, scope = $0["scope"].stringValue {
                let newSession = self.copy() as! Session
                newSession.accessToken = accessToken
                newSession.accessTokenExpireDate = NSDate(timeIntervalSinceNow: expires)
                newSession.scope = scope
                newSession.refreshToken = $0["refresh_token"].stringValue
                return .Success(newSession)
            }
            return .Failure(.Parsing)
            }) { result in
                completion(SimpleAPIResponse(result))
        }
        request.start()
    }

    ////////////////////////////////////////////////////////////////////////////
}
#endif

////////////////////////////////////////////////////////////////////////////


// MARK: - Soundcloud
////////////////////////////////////////////////////////////////////////////

public class Soundcloud: NSObject {
    // MARK: Properties
    ////////////////////////////////////////////////////////////////////////////

    #if os(iOS) || os(OSX)
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
    #endif

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

    - parameter URI:        The URI to lookup
    - parameter completion: The closure that will be called when the result is ready or upon error
    */
    public static func resolve(URI: String, completion: SimpleAPIResponse<ResolveResponse> -> Void) {
        guard let clientIdentifier = Soundcloud.clientIdentifier else {
            completion(SimpleAPIResponse(.CredentialsNotSet))
            return
        }

        let URL = NSURL(string: "https://api.soundcloud.com/resolve")!
        let parameters = ["client_id": clientIdentifier, "url": URI]

        let request = Request(URL: URL, method: .GET, parameters: parameters, parse: {
            if let user = User(JSON: $0) {
                return .Success(ResolveResponse(users: [user], tracks: nil, playlist: nil))
            }

            if let playlist = Playlist(JSON: $0) {
                return .Success(ResolveResponse(users: nil, tracks: nil, playlist: playlist))
            }

            if let track = Track(JSON: $0) {
                return .Success(ResolveResponse(users: nil, tracks: [track], playlist: nil))
            }

            let users = $0.flatMap { return User(JSON: $0) }
            if let users = users where users.count > 0 {
                return .Success(ResolveResponse(users: users, tracks: nil, playlist: nil))
            }

            let tracks = $0.flatMap { return Track(JSON: $0) }
            if let tracks = tracks where tracks.count > 0 {
                return .Success(ResolveResponse(users: nil, tracks: tracks, playlist: nil))
            }

            return .Failure(.Parsing)
            }) { result in
                completion(SimpleAPIResponse(result))
        }
        request.start()
    }

    ////////////////////////////////////////////////////////////////////////////
}

////////////////////////////////////////////////////////////////////////////
