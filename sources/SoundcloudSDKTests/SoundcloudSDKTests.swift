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


    // MARK: Caching tests
    ////////////////////////////////////////////////////////////////////////////

    func testApp() {
        var app = App(identifier: 123, URL: NSURL(), permalinkURL: NSURL(), name: "name")
        var data = app.toData()
        var newApp = App.fromData(data)

        XCTAssert(app == newApp, "App and newApp should be equal in any point")
        XCTAssert(app.identifier == newApp.identifier, "App and newApp should be equal in any point")
        XCTAssert(app.URL == newApp.URL, "App and newApp should be equal in any point")
        XCTAssert(app.permalinkURL == newApp.permalinkURL, "App and newApp should be equal in any point")
        XCTAssert(app.name == newApp.name, "App and newApp should be equal in any point")

        app = App(identifier: 123, URL: nil, permalinkURL: nil, name: "name")
        data = app.toData()
        newApp = App.fromData(data)

        XCTAssert(app == newApp, "App and newApp should be equal in any point")
        XCTAssert(app.identifier == newApp.identifier, "App and newApp should be equal in any point")
        XCTAssert(app.URL == newApp.URL, "App and newApp should be equal in any point")
        XCTAssert(app.permalinkURL == newApp.permalinkURL, "App and newApp should be equal in any point")
        XCTAssert(app.name == newApp.name, "App and newApp should be equal in any point")

        let apps = [app, app, app, app]
        data = NSKeyedArchiver.archivedDataWithRootObject(apps.map { app -> NSData in
            var app = app
            return app.toData()
        })
        let newApps = (NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [NSData]).map {
            App.fromData($0)
        }

        XCTAssert(apps == newApps, "Apps and newApps should be equal in any point")
    }

    ////////////////////////////////////////////////////////////////////////////
}
