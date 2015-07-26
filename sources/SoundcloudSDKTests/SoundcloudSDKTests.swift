//
//  SoundcloudSDKTests.swift
//  SoundcloudSDKTests
//
//  Created by Kevin DELANNOY on 24/02/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import XCTest

class SoundcloudSDKTests: XCTestCase {
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
