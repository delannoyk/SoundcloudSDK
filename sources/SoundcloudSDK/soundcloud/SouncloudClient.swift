//
//  SoundcloudClient.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 25/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation
#if os(iOS) || os(OSX)
    import KeychainAccess
#endif

// MARK: - Errors

public struct BasicError {
    public let code: String
    public let description: String
}

public enum SoundcloudError: Error {
    case credentialsNotSet
    case notFound
    case forbidden
    case parsing
    case unknown
    case network(Error)
    #if os(iOS) || os(OSX)
    case needsLogin
    case loginError(BasicError)
    #endif
}

extension SoundcloudError: RequestError {
    init(networkError: Error) {
        self = .network(networkError)
    }

    init(jsonError: Error) {
        self = .parsing
    }

    init?(httpURLResponse: HTTPURLResponse) {
        switch httpURLResponse.statusCode {
        case 200, 201:
            return nil
        case 401:
            self = .forbidden
        case 404:
            self = .notFound
        default:
            self = .unknown
        }
    }
}

extension SoundcloudError: Equatable { }

public func ==(lhs: SoundcloudError, rhs: SoundcloudError) -> Bool {
    switch (lhs, rhs) {
    case (.credentialsNotSet, .credentialsNotSet):
        return true
    case (.notFound, .notFound):
        return true
    case (.forbidden, .forbidden):
        return true
    case (.parsing, .parsing):
        return true
    case (.unknown, .unknown):
        return true
    case (.network(let e1), .network(let e2)):
        return e1 as NSError == e2 as NSError
    default:
        //TODO: find a better way to express this
        #if os(iOS) || os(OSX)
            switch (lhs, rhs) {
            case (.needsLogin, .needsLogin):
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
    init(error: SoundcloudError) {
        self.init(response: .failure(error), nextPageURL: nil) { _ in .failure(error) }
    }

    init(JSON: JSONObject, parse: @escaping (JSONObject) -> Result<[T], SoundcloudError>) {
        self.init(response: parse(JSON["collection"]), nextPageURL: JSON["next_href"].urlValue, parse: parse)
    }
}

// MARK: - Session

#if os(iOS) || os(OSX)
@objc(SoundcloudSession)
public class Session: NSObject, NSCoding, NSCopying {
    //First session info
    public private(set) var authorizationCode: String

    //Token
    public fileprivate(set) var accessToken: String?
    public fileprivate(set) var accessTokenExpireDate: Date?

    public fileprivate(set) var scope: String?

    //Future session
    public fileprivate(set) var refreshToken: String?

    // MARK: Initialization

    init(authorizationCode: String) {
        self.authorizationCode = authorizationCode
    }

    // MARK: NSCoding

    private static let authorizationCodeKey = "authorizationCodeKey"
    private static let accessTokenKey = "accessTokenKey"
    private static let accessTokenExpireDateKey = "accessTokenExpireDateKey"
    private static let scopeKey = "scopeKey"
    private static let refreshTokenKey = "refreshTokenKey"

    required public init?(coder aDecoder: NSCoder) {
        guard let authCode = aDecoder.decodeObject(forKey: Session.authorizationCodeKey) as? String else {
            return nil
        }

        authorizationCode = authCode
        accessToken = aDecoder.decodeObject(forKey: Session.accessTokenKey) as? String
        accessTokenExpireDate = aDecoder.decodeObject(forKey: Session.accessTokenExpireDateKey) as? Date
        scope = aDecoder.decodeObject(forKey: Session.scopeKey) as? String
        refreshToken = aDecoder.decodeObject(forKey: Session.refreshTokenKey) as? String
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(authorizationCode, forKey: Session.authorizationCodeKey)
        aCoder.encode(accessToken, forKey: Session.accessTokenKey)
        aCoder.encode(accessTokenExpireDate, forKey: Session.accessTokenExpireDateKey)
        aCoder.encode(scope, forKey: Session.scopeKey)
        aCoder.encode(refreshToken, forKey: Session.refreshTokenKey)
    }


    // MARK: NSCopying

    public func copy(with zone: NSZone?) -> Any {
        let session = Session(authorizationCode: authorizationCode)
        session.accessToken = accessToken
        session.accessTokenExpireDate = accessTokenExpireDate
        session.scope = scope
        session.refreshToken = refreshToken
        return session
    }
}

extension Session {
    // MARK: Public methods

    /**
    Logs a user in. This method will present an UIViewController over `displayViewController`
    that will load a web view so that user is available to log in

    - parameter displayViewController: An UIViewController that is in the view hierarchy
    - parameter completion:            The closure that will be called when the user is logged in or upon error
    */
    @available(*, deprecated: 0.9, message: "Login has been moved to Soundcloud. Please use `Soundcloud.login().`")
    public static func login(in displayViewController: ViewController, completion: @escaping (SimpleAPIResponse<Session>) -> Void) {
        SoundcloudClient.login(in: displayViewController, completion: completion)
    }

    /**
    Refresh the token of the logged user. You should call this method when you get a 401 error on
    API calls

    - parameter completion: The closure that will be called when the session is refreshed or upon error
    */
    public func refreshSession(completion: @escaping (SimpleAPIResponse<Session>) -> Void) {
        _refreshToken { result in
            if let session = result.response.result {
                SoundcloudClient.session = session
            }
            completion(result)
        }
    }

    /**
    Logs out the current user. This is a straight-forward call.
    */
    @available(*, deprecated: 0.9, message: "Logout has been moved to Soundcloud. Please use `Soundcloud.destroySession()`.")
    public func destroy() {
        SoundcloudClient.destroySession()
    }

    /**
    Fetch current user's profile.

    **This method requires a Session.**

    - parameter completion: The closure that will be called when the profile is loaded or upon error
    */
    public func me(completion: @escaping (SimpleAPIResponse<User>) -> Void) {
        guard let clientIdentifier = SoundcloudClient.clientIdentifier else {
            completion(SimpleAPIResponse(error: .credentialsNotSet))
            return
        }

        guard let oauthToken = accessToken else {
            completion(SimpleAPIResponse(error: .needsLogin))
            return
        }

        let url = URL(string: "https://api.soundcloud.com/me")!
        let parameters = ["client_id": clientIdentifier, "oauth_token": oauthToken]

        let request = Request(url: url, method: .get, parameters: parameters, parse: {
            if let user = User(JSON: $0) {
                return .success(user)
            }
            return .failure(.parsing)
        }) { result in
            completion(SimpleAPIResponse(result: result))
        }
        request.start()
    }

    /**
     Fetch current user's profile.

     **This method requires a Session.**

     - parameter completion: The closure that will be called when the activities are loaded or upon error
     */
    public func activities(completion: @escaping (PaginatedAPIResponse<Activity>) -> Void) {
        guard let clientIdentifier = SoundcloudClient.clientIdentifier else {
            completion(PaginatedAPIResponse(error: .credentialsNotSet))
            return
        }

        guard let oauthToken = accessToken else {
            completion(PaginatedAPIResponse(error: .needsLogin))
            return
        }

        let url = URL(string: "https://api.soundcloud.com/me/activities")!
        let parameters = ["client_id": clientIdentifier, "oauth_token": oauthToken, "linked_partitioning": "true"]

        let parse = { (JSON: JSONObject) -> Result<[Activity], SoundcloudError> in
            guard let activities = JSON.flatMap(transform: { Activity(JSON: $0) }) else {
                return .failure(.parsing)
            }
            return .success(activities)
        }

        let request = Request(url: url, method: .get, parameters: parameters, parse: { JSON -> Result<PaginatedAPIResponse<Activity>, SoundcloudError> in
            return .success(PaginatedAPIResponse(JSON: JSON, parse: parse))
        }) { result in
            completion(result.recover { PaginatedAPIResponse(error: $0) })
        }
        request.start()
    }

    // MARK: Token

    func getToken(completion: @escaping (SimpleAPIResponse<Session>) -> Void) {
        guard let clientId = SoundcloudClient.clientIdentifier,
            let clientSecret = SoundcloudClient.clientSecret,
            let redirectURI = SoundcloudClient.redirectURI else {
                completion(SimpleAPIResponse(error: .credentialsNotSet))
                return
        }

        let parameters = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code",
            "code": authorizationCode]
        token(parameters: parameters, completion: completion)
    }

    func _refreshToken(completion: @escaping (SimpleAPIResponse<Session>) -> Void) {
        guard let clientId = SoundcloudClient.clientIdentifier,
            let clientSecret = SoundcloudClient.clientSecret,
            let redirectURI = SoundcloudClient.redirectURI else {
                completion(SimpleAPIResponse(error: .credentialsNotSet))
                return
        }

        guard let refreshToken = refreshToken else {
            completion(SimpleAPIResponse(error: .needsLogin))
            return
        }

        let parameters = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "refresh_token",
            "code": authorizationCode,
            "refresh_token": refreshToken]
        token(parameters: parameters, completion: completion)
    }

    private func token(parameters: HTTPParametersConvertible, completion: @escaping (SimpleAPIResponse<Session>) -> Void) {
        let url = URL(string: "https://api.soundcloud.com/oauth2/token")!

        let request = Request(url: url, method: .post, parameters: parameters, parse: {
            if let accessToken = $0["access_token"].stringValue,
                let expires = $0["expires_in"].doubleValue,
                let scope = $0["scope"].stringValue {
                let newSession = self.copy() as! Session
                newSession.accessToken = accessToken
                newSession.accessTokenExpireDate = Date(timeIntervalSinceNow: expires)
                newSession.scope = scope
                newSession.refreshToken = $0["refresh_token"].stringValue
                return .success(newSession)
            }
            return .failure(.parsing)
        }) { result in
            completion(SimpleAPIResponse(result: result))
        }
        request.start()
    }
}
#endif

// MARK: - SoundcloudClient

public class SoundcloudClient: NSObject {
    // MARK: Properties

    /// Your Soundcloud app client identifier
    public static var clientIdentifier: String?

    /// Your Soundcloud app client secret
    public static var clientSecret: String?

    /// Your Soundcloud redirect URI
    public static var redirectURI: String?


    // MARK: Session Management

    #if os(iOS) || os(OSX)

    private static let sessionKey = "sessionKey"

    private static let keychain = Keychain(server: "https://soundcloud.com", protocolType: .https)


    /// The session property is only set when a user has logged in.
    public fileprivate(set) static var session: Session? = {
        if let data = keychain[data: sessionKey],
            let session = NSKeyedUnarchiver.unarchiveObject(with: data) as? Session {
            return session
        }
        return nil
    }() {
        willSet(newSession) {
            if let session = newSession {
                let data = NSKeyedArchiver.archivedData(withRootObject: session)
                keychain[data: sessionKey] = data
            } else {
                keychain[sessionKey] = nil
            }
        }
    }

    /**
     Logs a user in. This method will present an UIViewController over `displayViewController`
     that will load a web view so that user is available to log in

     - parameter displayViewController: An UIViewController that is in the view hierarchy
     - parameter completion:            The closure that will be called when the user is logged in or upon error
     */
    public static func login(in displayViewController: ViewController, completion: @escaping (SimpleAPIResponse<Session>) -> Void) {
        authorize(in: displayViewController) { result in
            if let session = result.response.result {
                session.getToken { result in
                    SoundcloudClient.session = result.response.result
                    completion(result)
                }
            } else {
                completion(result)
            }
        }
    }

    /**
     Logs out the current user. This is a straight-forward call.
     */
    public static func destroySession() {
        SoundcloudClient.session = nil
    }

    static func authorize(in displayViewController: ViewController, completion: @escaping (SimpleAPIResponse<Session>) -> Void) {
        guard let clientIdentifier = SoundcloudClient.clientIdentifier, let redirectURI = SoundcloudClient.redirectURI else {
            completion(SimpleAPIResponse(error: .credentialsNotSet))
            return
        }

        let url = URL(string: "https://soundcloud.com/connect")!

        let parameters = ["client_id": clientIdentifier,
                          "redirect_uri": redirectURI,
                          "response_type": "code"]

        let web = SoundcloudWebViewController()
        web.autoDismissURI = redirectURI
        web.url = url.appendingQueryString(parameters.queryString)
        web.onDismiss = { url in
            if let accessCode = url?.query?.queryDictionary["code"] {
                let session = Session(authorizationCode: accessCode)
                completion(SimpleAPIResponse(value: session))
            } else if let code = url?.query?.queryDictionary["error"],
                let description = url?.query?.queryDictionary["error_description"] {
                completion(SimpleAPIResponse(error: .loginError(BasicError(code: code, description: description))))
            } else {
                completion(SimpleAPIResponse(error: .needsLogin))
            }
        }

        #if os(OSX)
            web.title = "Soundcloud"
            web.preferredContentSize = displayViewController.view.bounds.size

            displayViewController.presentViewControllerAsSheet(web)
        #else
            web.navigationItem.title = "Soundcloud"

            let nav = UINavigationController(rootViewController: web)
            displayViewController.present(nav, animated: true, completion: nil)
        #endif
    }

    #endif


    // MARK: Resolve

    /// A resolve response can either be a/some User(s) or a/some Track(s) or a Playlist.
    public typealias ResolveResponse = (users: [User]?, tracks: [Track]?, playlist: Playlist?)

    /**
    Resolve allows you to lookup and access API resources when you only know the SoundCloud.com URL.

    - parameter URI:        The URI to lookup
    - parameter completion: The closure that will be called when the result is ready or upon error
    */
    public static func resolve(URI: String, completion: @escaping (SimpleAPIResponse<ResolveResponse>) -> Void) {
        guard let clientIdentifier = SoundcloudClient.clientIdentifier else {
            completion(SimpleAPIResponse(error: .credentialsNotSet))
            return
        }

        let url = URL(string: "https://api.soundcloud.com/resolve")!
        let parameters = ["client_id": clientIdentifier, "url": URI]

        let request = Request(url: url, method: .get, parameters: parameters, parse: {
            if let user = User(JSON: $0) {
                return .success(ResolveResponse(users: [user], tracks: nil, playlist: nil))
            }

            if let playlist = Playlist(JSON: $0) {
                return .success(ResolveResponse(users: nil, tracks: nil, playlist: playlist))
            }

            if let track = Track(JSON: $0) {
                return .success(ResolveResponse(users: nil, tracks: [track], playlist: nil))
            }

            let users = $0.flatMap { User(JSON: $0) }
            if let users = users, users.count > 0 {
                return .success(ResolveResponse(users: users, tracks: nil, playlist: nil))
            }

            let tracks = $0.flatMap { Track(JSON: $0) }
            if let tracks = tracks, tracks.count > 0 {
                return .success(ResolveResponse(users: nil, tracks: tracks, playlist: nil))
            }

            return .failure(.parsing)
        }) { result in
            completion(SimpleAPIResponse(result: result))
        }
        request.start()
    }
}
