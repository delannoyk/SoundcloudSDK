SoundcloudSDK
=============
[![Build Status](https://travis-ci.org/delannoyk/SoundcloudSDK.svg)](https://travis-ci.org/delannoyk/SoundcloudSDK)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Cocoapods Compatible](https://img.shields.io/cocoapods/v/Soundcloud.svg)
![Platform iOS | tvOS](https://img.shields.io/badge/platform-iOS%20%7C%20tvOS%20%7C%20OSX-lightgrey.svg)
[![Contact](https://img.shields.io/badge/contact-%40kdelannoy-blue.svg)](https://twitter.com/kdelannoy)

SoundcloudSDK is a framework written in Swift over Soundcloud API.

## Installation

### Swift 2.2
* Cocoapods: `pod 'Soundcloud'`
* Carthage: `github "delannoyk/SoundcloudSDK"`

### Swift 3.0 (1st preview)
* Cocoapods: `pod 'Soundcloud', :git => 'https://github.com/SoundcloudSDK', :branch => 'develop'`
* Carthage: `github "delannoyk/SoundcloudSDK" "develop"`

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
    Tracks.track(identifier: Int, completion: SimpleAPIResponse<Track> -> Void)
    ```
* Load tracks by identifiers

    ```swift
    Tracks.tracks(identifiers: [Int], completion: SimpleAPIResponse<[Track]> -> Void)
    ```
* Get list of comments

    ```swift
    let track: Track
    track.comments(completion: PaginatedAPIResponse<Comment> -> Void)
    ```
* Get list of favoriters

    ```swift
    let track: Track
    track.favoriters(completion: PaginatedAPIResponse<User> -> Void)
    ```
    
* Search tracks

    ```swift
    let queries: [SearchQueryOptions] = [
        .QueryString("The text to search"),
        .Tags(["list", "of", "tags", "to", "search", "for"]),
        .Genres(["punk", "rock", "..."]),
        .Types([TrackType.Live, TrackType.Demo])
    ]
    Track.search(queries, completion: PaginatedAPIResponse<Track> -> Void)
    ```
    
* Relative tracks
    ```swift
    Track.relatedTracks(identifier: Int, completion: SimpleAPIResponse<[Track]> -> Void)
    ```

### User

* Load user by identifier

    ```swift
    User.user(identifier: Int, completion: SimpleAPIResponse<User> -> Void)
    ```
* Load list of user's tracks

    ```swift
    let user: User
    user.tracks(completion: PaginatedAPIResponse<Track> -> Void)
    ```
* Load list of user's comments

    ```swift
    let user: User
    user.comments(completion: PaginatedAPIResponse<Comment> -> Void)
    ```
* Load list of user's favorite tracks

    ```swift
    let user: User
    user.favorites(completion: PaginatedAPIResponse<Track> -> Void)
    ```
* Load list of user's followers

    ```swift
    let user: User
    user.followers(completion: PaginatedAPIResponse<User> -> Void)
    ```
* Load list of user's followings

    ```swift
    let user: User
    user.followings(completion: PaginatedAPIResponse<User> -> Void)
    ```

### Resolve

```swift
Soundcloud.resolve(URI: String, completion: SimpleAPIResponse<ResolveResponse> -> Void)
```
where `ResolveResponse`is a typealias for `ResolveResponse = (users: [User]?, tracks: [Track]?, playlist: Playlist?)`

### Login

The login method implements the standard OAuth2 of Soundcloud. Some private methods requires the user to be logged in. These are listed below.

#### Session

* Login

    ```swift
    Session.login(displayViewController: UIViewController, completion: SimpleAPIResponse<Session> -> Void)
    ```
* Refresh token

    ```swift
    let session = Soundcloud.session
    session?.refreshSession(completion: SimpleAPIResponse<Session> -> Void)
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
    session?.me(completion: SimpleAPIResponse<User> -> Void)
    ```
* Comment a track

    ```swift
    let track: Track
    track.comment(body: String, timestamp: NSTimeInterval, completion: SimpleAPIResponse<Comment> -> Void)
    ```
* Favorite a track

    ```swift
    let track: Track
    track.favorite(userIdentifier: Int, completion: SimpleAPIResponse<Bool> -> Void)
    ```
* Unfavorite a track

    ```swift
    let track: Track
    track.unfavorite(userIdentifier: Int, completion: SimpleAPIResponse<Bool> -> Void)
    ```
* Follow a user

    ```swift
    let user: User
    user.follow(userIdentifier: Int, completion: SimpleAPIResponse<Bool> -> Void)
    ```
* Unfollow a user

    ```swift
    let user: User
    user.unfollow(userIdentifier: Int, completion: SimpleAPIResponse<Bool> -> Void)
    ```

## Next steps

* Add unit tests
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
