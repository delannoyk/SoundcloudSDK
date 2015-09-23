//
//  RequestTests.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 25/07/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import XCTest

class RequestTests: XCTestCase {
    // MARK: HTTPParametersConvertible
    ////////////////////////////////////////////////////////////////////////////

    func testGETString() {
        let method = HTTPMethod.GET
        let URL = NSURL(string: "http://github.com")!
        let parameters = "test=123"
        let URLRequest = method.URLRequest(URL, parameters: parameters)

        let expectedValue = URL.absoluteString + "?" + parameters

        XCTAssert(URLRequest.URL?.absoluteString == expectedValue, "Test failed: URLRequest.URL isn't what it's supposed to be.")
    }

    func testGETDictionary() {
        let method = HTTPMethod.GET
        let URL = NSURL(string: "http://github.com")!
        let parameters = ["test": "123"]
        let URLRequest = method.URLRequest(URL, parameters: parameters)

        let expectedValue = URL.absoluteString + "?" + parameters.queryString

        XCTAssert(URLRequest.URL?.absoluteString == expectedValue, "Test failed: URLRequest.URL isn't what it's supposed to be.")
    }

    func testPOSTString() {
        let method = HTTPMethod.POST
        let URL = NSURL(string: "http://github.com")!
        let parameters = "test=123"
        let URLRequest = method.URLRequest(URL, parameters: parameters)

        let expectedValue = parameters.dataUsingEncoding(NSUTF8StringEncoding)!

        XCTAssert(URLRequest.URL == URL, "Test failed: URLRequest.URL isn't what it's supposed to be.")
        XCTAssert(URLRequest.HTTPBody == expectedValue, "Test failed: URLRequest.HTTPBody isn't what it's supposed to be.")
    }

    func testPOSTDictionary() {
        let method = HTTPMethod.POST
        let URL = NSURL(string: "http://github.com")!
        let parameters = ["test": "123"]
        let URLRequest = method.URLRequest(URL, parameters: parameters)

        let expectedValue = parameters.queryString.dataUsingEncoding(NSUTF8StringEncoding)!

        XCTAssert(URLRequest.URL == URL, "Test failed: URLRequest.URL isn't what it's supposed to be.")
        XCTAssert(URLRequest.HTTPBody == expectedValue, "Test failed: URLRequest.HTTPBody isn't what it's supposed to be.")
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: URL Encode
    ////////////////////////////////////////////////////////////////////////////

    func testURLEncoding() {
        let parameters = [
            "1": "1",
            "2": "2 2",
            "3": "3 3 3",
            "4": "4@",
            "5": "%@ & test ="
        ]

        XCTAssert(parameters["1"]!.URLEncodedValue == "1", "1 should be transformed to 1")
        XCTAssert(parameters["2"]!.URLEncodedValue == "2%202", "2 2 should be transformed to 2%202")
        XCTAssert(parameters["3"]!.URLEncodedValue == "3%203%203", "3 3 3 should be transformed to 3%203%203")
        XCTAssert(parameters["4"]!.URLEncodedValue == "4%40", "4@ should be transformed to 4%40")
        XCTAssert(parameters["5"]!.URLEncodedValue == "%25%40%20%26%20test%20%3D", "%@ should be transformed to %25%40%20%26%20test%20%3D")
    }

    ////////////////////////////////////////////////////////////////////////////
}
