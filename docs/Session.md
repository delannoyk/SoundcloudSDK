<p align="center">
[**Session**](Session.md) &bull; [User](User.md) &bull; [Track](Track.md) &bull; [Resolve](Resolve.md)
</div>

Session
===============

Some private methods requires the user to be logged in with an valid SoundCloud session. This session is persisted locally in the keychain.

### Login:

The login method implements the standard OAuth2 of SoundCloud.

Swift 3.0
```swift
Session.login(in: ViewController, completion: @escaping (SimpleAPIResponse<Session>) -> Void)
```

Swift 2.3
```swift
Session.login(displayViewController: UIViewController, completion: SimpleAPIResponse<Session> -> Void)
```


### Refresh token:

Swift 3.0, 2.3
```swift
let session = Soundcloud.session
session?.refreshSession(completion: SimpleAPIResponse<Session> -> Void)
```

### Logout:

Swift 3.0, 2.3
```swift
let session = Soundcloud.session
session?.destroy()
```

Accessing the Session
=====================

The session can be accessed directly

```swift
let session: Session? = Soundcloud.session
```

The following OAuth values are exposed as read-only properties:

Swift 3.0
```swift
let session: Session
let authorizationCode: String = session.authorizationCode
let accessToken: String? = session.accessToken
let accessTokenExpireDate: Date? = session.accessTokenExpireDate
let scope: String? = session.scope
let refreshToken: String? = session.refreshToken
```
