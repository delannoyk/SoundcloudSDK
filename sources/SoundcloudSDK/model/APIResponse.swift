//
//  APIResponse.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 21/10/15.
//  Copyright © 2015 Kevin Delannoy. All rights reserved.
//

import UIKit

public protocol APIResponse {
    typealias U
    var response: Result<U> { get }
}

public struct SimpleAPIResponse<T>: APIResponse {
    public typealias U = T
    public let response: Result<T>

    // MARK: Initialization
    ////////////////////////////////////////////////////////////////////////////

    internal init(_ response: Result<T>) {
        self.response = response
    }

    ////////////////////////////////////////////////////////////////////////////
}

public struct PaginatedAPIResponse<T>: APIResponse {
    public typealias U = [T]
    public let response: Result<[T]>

    private let nextPageURL: NSURL?
    private let parse: JSONObject -> Result<[T]>

    // MARK: Initialization
    ////////////////////////////////////////////////////////////////////////////

    internal init(response: Result<[T]>, nextPageURL: NSURL?, parse: JSONObject -> Result<[T]>) {
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
                parse: { JSON in
                    return .Success(PaginatedAPIResponse(response: self.parse(JSON["collection"]),
                        nextPageURL: JSON["next_href"].URLValue,
                        parse: self.parse))
                }) { result, response in
                    completion(result.result!)
            }
            request.start()
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
