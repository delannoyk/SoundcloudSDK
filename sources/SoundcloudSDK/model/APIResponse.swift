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

    internal init(_ response: Result<T, SoundcloudError>) {
        self.response = response
    }

    internal init(_ error: SoundcloudError) {
        self.response = .Failure(error)
    }

    internal init(_ value: T) {
        self.response = .Success(value)
    }

    ////////////////////////////////////////////////////////////////////////////
}

public struct PaginatedAPIResponse<T>: APIResponse {
    public typealias U = [T]
    public let response: Result<[T], SoundcloudError>

    private let nextPageURL: NSURL?
    private let parse: JSONObject -> Result<[T], SoundcloudError>

    // MARK: Initialization
    ////////////////////////////////////////////////////////////////////////////

    internal init(response: Result<[T], SoundcloudError>,
        nextPageURL: NSURL?,
        parse: JSONObject -> Result<[T], SoundcloudError>) {
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

    public func fetchNextPage(completion: PaginatedAPIResponse<T> -> Void) {
        if let nextPageURL = nextPageURL {
            let request = Request(URL: nextPageURL,
                method: .GET,
                parameters: nil,
                parse: { JSON -> Result<PaginatedAPIResponse, SoundcloudError> in
                    return .Success(PaginatedAPIResponse(JSON, parse: self.parse))
                }) { result in
                    completion(result.result!)
            }
            request.start()
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
