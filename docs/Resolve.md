<p align="center">
[Session](Session.md) &bull; [User](User.md) &bull; [Track](Track.md) &bull; [**Resolve**](Resolve.md)
</div>

Resolve
===============

Swift 3.0, 2.3
```swift
Soundcloud.resolve(URI: String, completion: SimpleAPIResponse<ResolveResponse> -> Void)
```

where `ResolveResponse` is a typealias for `ResolveResponse = (users: [User]?, tracks: [Track]?, playlist: Playlist?)`
