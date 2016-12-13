<p align="center">
[Session](Session.md) &bull; [**User**](User.md) &bull; [Track](Track.md) &bull; [Resolve](Resolve.md)
</div>

User
===============

### Load user by identifier:

Swift 3.0, 2.3
```swift
User.user(identifier: Int, completion: SimpleAPIResponse<User> -> Void)
```

### Load list of user's tracks:

Swift 3.0, 2.3
```swift
let user: User
user.tracks(completion: PaginatedAPIResponse<Track> -> Void)
```

### Load list of user's comments:

Swift 3.0, 2.3
```swift
let user: User
user.comments(completion: PaginatedAPIResponse<Comment> -> Void)
```

### Load list of user's favorite tracks:

Swift 3.0, 2.3
```swift
let user: User
user.favorites(completion: PaginatedAPIResponse<Track> -> Void)
```

### Load list of user's followers:

Swift 3.0, 2.3
```swift
let user: User
user.followers(completion: PaginatedAPIResponse<User> -> Void)
```

### Load list of user's followings:

Swift 3.0, 2.3
```swift
let user: User
user.followings(completion: PaginatedAPIResponse<User> -> Void)
```

Private Methods
---------------

### User's profile:

Swift 3.0, 2.3
```swift
let session = Soundcloud.session
session?.me(completion: SimpleAPIResponse<User> -> Void)
```

### Follow a user:

Swift 3.0, 2.3
```swift
let user: User
user.follow(userIdentifier: Int, completion: SimpleAPIResponse<Bool> -> Void)
```

### Unfollow a user:

Swift 3.0, 2.3
```swift
let user: User
user.unfollow(userIdentifier: Int, completion: SimpleAPIResponse<Bool> -> Void)
```
