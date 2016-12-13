SoundcloudSDK
=============
[![Build Status](https://travis-ci.org/delannoyk/SoundcloudSDK.svg)](https://travis-ci.org/delannoyk/SoundcloudSDK)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Cocoapods Compatible](https://img.shields.io/cocoapods/v/Soundcloud.svg)
![Platform iOS | tvOS](https://img.shields.io/badge/platform-iOS%20%7C%20tvOS%20%7C%20OSX-lightgrey.svg)
[![Contact](https://img.shields.io/badge/contact-%40kdelannoy-blue.svg)](https://twitter.com/kdelannoy)

SoundcloudSDK is a framework written in Swift over Soundcloud API.

## Installation

### Swift 3.0
* CocoaPods: `pod 'Soundcloud'`
* Carthage: `github "delannoyk/SoundcloudSDK"`

### Swift 2.3
* CocoaPods: `pod 'Soundcloud', '~> 0.9.2'`
* Carthage: `github "delannoyk/SoundcloudSDK" == 0.9.2`

### Configuration

First step to use the SDK is to configure it to use your application credentials:

```swift
Soundcloud.clientIdentifier = "YOUR_CLIENT_IDENTIFIER"
Soundcloud.clientSecret  = "YOUR_CLIENT_SECRET"
Soundcloud.redirectURI = "YOUR_REDIRECT_URI"
```

After that, you're good to go.

## Usage

For full usage please see the [documentation](docs/).

**Examples**

You can search for tracks like this:
```swift
let queries: [SearchQueryOptions] = [
    .QueryString("The text to search"),
    .Tags(["list", "of", "tags", "to", "search", "for"]),
    .Genres(["punk", "rock", "..."]),
    .Types([TrackType.Live, TrackType.Demo])
]
Track.search(queries, completion: PaginatedAPIResponse<Track> -> Void)
```

If your client is logged in, you could favorite one of those tracks on their behalf like this:

```swift
let track: Track
track.favorite(userIdentifier: Int, completion: SimpleAPIResponse<Bool> -> Void)
```

## Example App

An example application is included in `source/SoundcloudAppTest`. Be sure to set your own SoundCloud app values in `AppDelegate`.

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
