//
//  SoundcloudSDKTests.swift
//  SoundcloudSDKTests
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import UIKit
import XCTest

class SoundcloudSDKTests: XCTestCase {
    // MARK: HTTPParametersConvertible
    ////////////////////////////////////////////////////////////////////////////

    func testGETString() {
        let method = HTTPMethod.GET
        let URL = NSURL(string: "http://github.com")!
        let parameters = "test=123"
        let URLRequest = method.URLRequest(URL, parameters: parameters)

        let expectedValue = URL.absoluteString! + "?" + parameters

        XCTAssert(URLRequest.URL?.absoluteString! == expectedValue, "Test failed: URLRequest.URL isn't what it's supposed to be.")
    }

    func testGETDictionary() {
        let method = HTTPMethod.GET
        let URL = NSURL(string: "http://github.com")!
        let parameters = ["test": "123"]
        let URLRequest = method.URLRequest(URL, parameters: parameters)

        let expectedValue = URL.absoluteString! + "?" + parameters.queryString

        XCTAssert(URLRequest.URL?.absoluteString! == expectedValue, "Test failed: URLRequest.URL isn't what it's supposed to be.")
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
}
