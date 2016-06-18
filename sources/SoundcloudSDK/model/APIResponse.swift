//
//  APIResponse.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 21/10/15.
//  Copyright © 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

public protocol APIResponse {
    associatedtype U
    var response: Result<U, SoundcloudError> { get }
}

public struct SimpleAPIResponse<T>: APIResponse {
    public typealias U = T
    public let response: Result<T, SoundcloudError>

    // MARK: Initialization
    ////////////////////////////////////////////////////////////////////////////

    init(_ response: Result<T, SoundcloudError>) {
        self.response = response
    }

    init(_ error: SoundcloudError) {
        self.response = .failure(error)
    }

    init(_ value: T) {
        self.response = .success(value)
    }

    ////////////////////////////////////////////////////////////////////////////
}

public struct PaginatedAPIResponse<T>: APIResponse {
    public typealias U = [T]
    public let response: Result<[T], SoundcloudError>

    private let nextPageURL: URL?
    private let parse: (JSONObject) -> Result<[T], SoundcloudError>

    // MARK: Initialization
    ////////////////////////////////////////////////////////////////////////////

    init(response: Result<[T], SoundcloudError>,
        nextPageURL: URL?,
        parse: (JSONObject) -> Result<[T], SoundcloudError>) {
            self.response = response
            self.nextPageURL = nextPageURL
            self.parse = parse
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Next page
    ////////////////////////////////////////////////////////////////////////////

    public var hasNextPage: Bool {
        return (nextPageURL != nil)
    }

    public func fetchNextPage(_ completion: (PaginatedAPIResponse<T>) -> Void) {
        if let nextPageURL = nextPageURL {
            let request = Request(url: nextPageURL,
                method: .GET,
                parameters: nil,
                parse: { JSON -> Result<PaginatedAPIResponse, SoundcloudError> in
                    return .success(PaginatedAPIResponse(JSON, parse: self.parse))
                }) { result in
                    completion(result.result!)
            }
            request.start()
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
