//
//  RequestTests.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 25/07/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import XCTest
import Foundation

class RequestTests: XCTestCase {
    // MARK: HTTPParametersConvertible

    func testGETString() {
        let method = HTTPMethod.get
        let url = URL(string: "http://github.com")!
        let parameters = "test=123"
        let urlRequest = method.urlRequest(url: url, parameters: parameters)

        let expectedValue = url.absoluteString + "?" + parameters

        XCTAssert(urlRequest.url?.absoluteString == expectedValue, "Test failed: URLRequest.URL isn't what it's supposed to be.")
    }

    func testGETDictionary() {
        let method = HTTPMethod.get
        let url = URL(string: "http://github.com")!
        let parameters = ["test": "123"]
        let urlRequest = method.urlRequest(url: url, parameters: parameters)

        let expectedValue = url.absoluteString + "?" + parameters.queryString

        XCTAssert(urlRequest.url?.absoluteString == expectedValue, "Test failed: URLRequest.URL isn't what it's supposed to be.")
    }

    func testPOSTString() {
        let method = HTTPMethod.post
        let url = URL(string: "http://github.com")!
        let parameters = "test=123"
        let urlRequest = method.urlRequest(url: url, parameters: parameters)

        let expectedValue = parameters.data(using: .utf8)!

        XCTAssert(urlRequest.url == url, "Test failed: URLRequest.URL isn't what it's supposed to be.")
        XCTAssert(urlRequest.httpBody == expectedValue, "Test failed: URLRequest.HTTPBody isn't what it's supposed to be.")
    }

    func testPOSTDictionary() {
        let method = HTTPMethod.post
        let url = URL(string: "http://github.com")!
        let parameters = ["test": "123"]
        let urlRequest = method.urlRequest(url: url, parameters: parameters)

        let expectedValue = parameters.queryString.data(using: .utf8)!

        XCTAssert(urlRequest.url == url, "Test failed: URLRequest.URL isn't what it's supposed to be.")
        XCTAssert(urlRequest.httpBody == expectedValue, "Test failed: URLRequest.HTTPBody isn't what it's supposed to be.")
    }

    // MARK: URL Encode

    func testURLEncoding() {
        let parameters = [
            "1": "1",
            "2": "2 2",
            "3": "3 3 3",
            "4": "4@",
            "5": "%@ & test ="
        ]

        XCTAssert(parameters["1"]!.urlEncodedValue == "1", "1 should be transformed to 1")
        XCTAssert(parameters["2"]!.urlEncodedValue == "2%202", "2 2 should be transformed to 2%202")
        XCTAssert(parameters["3"]!.urlEncodedValue == "3%203%203", "3 3 3 should be transformed to 3%203%203")
        XCTAssert(parameters["4"]!.urlEncodedValue == "4%40", "4@ should be transformed to 4%40")
        XCTAssert(parameters["5"]!.urlEncodedValue == "%25%40%20%26%20test%20%3D", "%@ should be transformed to %25%40%20%26%20test%20%3D")
    }
}
