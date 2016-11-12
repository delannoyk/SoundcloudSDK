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

    init(result: Result<T, SoundcloudError>) {
        response = result
    }

    init(error: SoundcloudError) {
        response = .failure(error)
    }

    init(value: T) {
        response = .success(value)
    }
}

public struct PaginatedAPIResponse<T>: APIResponse {
    public typealias U = [T]
    public let response: Result<[T], SoundcloudError>

    private let nextPageURL: URL?
    private let parse: (JSONObject) -> Result<[T], SoundcloudError>

    // MARK: Initialization

    init(response: Result<[T], SoundcloudError>,
        nextPageURL: URL?,
        parse: @escaping (JSONObject) -> Result<[T], SoundcloudError>) {
            self.response = response
            self.nextPageURL = nextPageURL
            self.parse = parse
    }

    // MARK: Next page

    public var hasNextPage: Bool {
        return (nextPageURL != nil)
    }

    @discardableResult
    public func fetchNextPage(completion: @escaping (PaginatedAPIResponse<T>) -> Void) -> CancelableOperation? {
        if let nextPageURL = nextPageURL {
            let request = Request(
                url: nextPageURL,
                method: .get,
                parameters: nil,
                parse: { JSON -> Result<PaginatedAPIResponse, SoundcloudError> in
                    return .success(PaginatedAPIResponse(JSON: JSON, parse: self.parse))
            }) { result in
                completion(result.recover { PaginatedAPIResponse(error: $0) })
            }
            request.start()
            return request
        }
        return nil
    }
}
