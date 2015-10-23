SoundcloudSDK
=============

SoundcloudSDK is a framework written in Swift over Soundcloud API.

## Installation

You have multiple choices here:
* Add it in your Podfile `pod 'Soundcloud'`

## Usage

### Configuration

First step to use the SDK is to configure it to use your application credentials:

```swift
Soundcloud.clientIdentifier = "YOUR_CLIENT_IDENTIFIER"
Soundcloud.clientSecret  = "YOUR_CLIENT_SECRET"
Soundcloud.redirectURI = "YOUR_REDIRECT_URI"
```
After that, you're good to go.

### Track

* Load track by identifier

    ```swift
    Tracks.track(identifier: Int, completion: Result<Track> -> Void)
    ```
* Load tracks by identifiers

    ```swift
    Tracks.tracks(identifiers: [Int], completion: Result<[Track]> -> Void)
    ```
* Get list of comments

    ```swift
    let track: Track
    track.comments(completion: Result<[Comment]> -> Void)
    ```
* Get list of favoriters

    ```swift
    let track: Track
    track.favoriters(completion: Result<[User]> -> Void)
    ```
    
* Search tracks

    ```swift
    let queries: [SearchQueryOptions] = [
        .QueryString("The text to search"),
        .Tags(["list", "of", "tags", "to", "search", "for"]),
        .Genres(["punk", "rock", "..."]),
        .Types([TrackType.Live, TrackType.Demo])
    ]
    Track.search(queries, completion: Result<[Track]> -> Void)
    ```

### User

* Load user by identifier

    ```swift
    User.user(identifier: Int, completion: Result<User> -> Void)
    ```
* Load list of user's tracks

    ```swift
    let user: User
    user.tracks(completion: Result<[Track]> -> Void)
    ```
* Load list of user's comments

    ```swift
    let user: User
    user.comments(completion: Result<[Comment]> -> Void)
    ```
* Load list of user's favorite tracks

    ```swift
    let user: User
    user.favorites(completion: Result<[Track]> -> Void)
    ```
* Load list of user's followers

    ```swift
    let user: User
    user.followers(completion: Result<[User]> -> Void)
    ```
* Load list of user's followings

    ```swift
    let user: User
    user.followings(completion: Result<[User]> -> Void)
    ```

### Resolve

The resolve method doesn't support playlists yet. It's coming :)

```swift
Soundcloud.resolve(URI: String, completion: Result<ResolveResponse> -> Void)
```
where `ResolveResponse`is a typealias for `ResolveResponse = (users: [User]?, tracks: [Track]?)`

### Login

The login method implements the standard OAuth2 of Soundcloud. Some private methods requires the user to be logged in. These are listed below.

#### Session

* Login

    ```swift
    Session.login(displayViewController: UIViewController, completion: Result<Session> -> Void)
    ```
* Refresh token

    ```swift
    let session = Soundcloud.session
    session?.refreshSession(completion: Result<Session> -> Void)
    ```
* Logout

    ```swift
    let session = Soundcloud.session
    session?.destroy()
    ```

#### Methods that require a Session
* User's profile

    ```swift
    let session = Soundcloud.session
    session?.me(completion: Result<User> -> Void)
    ```
* Comment a track

    ```swift
    let track: Track
    track.comment(body: String, timestamp: NSTimeInterval, completion: Result<Comment> -> Void)
    ```
* Favorite a track

    ```swift
    let track: Track
    track.favorite(userIdentifier: Int, completion: Result<Bool> -> Void)
    ```
* Follow a user

    ```swift
    let user: User
    user.follow(userIdentifier: Int, completion: Result<Bool> -> Void)
    ```
* Unfollow a user

    ```swift
    let user: User
    user.unfollow(userIdentifier: Int, completion: Result<Bool> -> Void)
    ```

## Next steps

* Add unit tests
* Better error support
* Analyse if it's necessary to ease up things to play a file (Integrate an audio player/a dependency ?)

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## License

The MIT License (MIT)

Copyright (c) 2015 Kevin Delannoy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
