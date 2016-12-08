<p align="center">
[Session](Session.md) &bull; [User](User.md) &bull; [**Track**](Track.md) &bull; [Resolve](Resolve.md)
</div>

Tracks
===============

### Load track by identifier:

Swift 3.0, 2.3
```swift
Tracks.track(identifier: Int, completion: SimpleAPIResponse<Track> -> Void)
```

### Load tracks by identifiers:

Swift 3.0, 2.3
```swift
Tracks.tracks(identifiers: [Int], completion: SimpleAPIResponse<[Track]> -> Void)
```

### Get list of comments:

Swift 3.0, 2.3
```swift
let track: Track
track.comments(completion: PaginatedAPIResponse<Comment> -> Void)
```

### Get list of favoriters:

Swift 3.0, 2.3
```swift
let track: Track
track.favoriters(completion: PaginatedAPIResponse<User> -> Void)
```

### Search tracks:

Swift 3.0
```swift
let queries: [SearchQueryOptions] = [
    .queryString("The text to search"),
    .tags(["list", "of", "tags", "to", "search", "for"]),
    .genres(["punk", "rock", "..."]),
    .types([TrackType.live, TrackType.demo]),
    .bpmFrom(80),
    .bpmTo(120)
]
Track.search(queries, completion: PaginatedAPIResponse<Track> -> Void)
```

Swift 2.3
```swift
let queries: [SearchQueryOptions] = [
    .QueryString("The text to search"),
    .Tags(["list", "of", "tags", "to", "search", "for"]),
    .Genres(["punk", "rock", "..."]),
    .Types([TrackType.Live, TrackType.Demo])
]
Track.search(queries, completion: PaginatedAPIResponse<Track> -> Void)
```

### Relative tracks:

Swift 3.0, 2.3
```swift
Track.relatedTracks(identifier: Int, completion: SimpleAPIResponse<[Track]> -> Void)
```

Private Methods
---------------

### Comment a track:

Swift 3.0
```swift
let track: Track
track.comment(body: String, timestamp: TimeInterval, completion: SimpleAPIResponse<Comment> -> Void)
```

Swift 2.3
```swift
let track: Track
track.comment(body: String, timestamp: NSTimeInterval, completion: SimpleAPIResponse<Comment> -> Void)
```

### Favorite a track:

Swift 3.0
```swift
let track: Track
track.favorite(completion: SimpleAPIResponse<Bool> -> Void)
```

Swift 2.3
```swift
let track: Track
track.favorite(userIdentifier: Int, completion: SimpleAPIResponse<Bool> -> Void)
```

### Unfavorite a track:

Swift 3.0
```swift
let track: Track
track.unfavorite(completion: SimpleAPIResponse<Bool> -> Void)
```

Swift 2.3
```swift
let track: Track
track.unfavorite(userIdentifier: Int, completion: SimpleAPIResponse<Bool> -> Void)
```
