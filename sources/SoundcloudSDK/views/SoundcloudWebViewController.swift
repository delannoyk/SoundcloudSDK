//
//  SoundcloudWebViewController.swift
//  Soundcloud
//
//  Created by Kevin DELANNOY on 18/07/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

#if os(OSX)
    import AppKit
    public typealias ViewController = NSViewController
#else
    import UIKit
    import OnePasswordExtension
    public typealias ViewController = UIViewController
#endif

import WebKit

internal class SoundcloudWebViewController: ViewController, WKNavigationDelegate {
    private lazy var webView = WKWebView()

    // MARK: View loading
    ////////////////////////////////////////////////////////////////////////////

    override func loadView() {
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        #if os(iOS)
        //Right button is OnePassword if available
        if OnePasswordExtension.sharedExtension().isAppExtensionAvailable() {
            let bundle = NSBundle(forClass: OnePasswordExtension.self)
            if let path = bundle.pathForResource("OnePasswordExtensionResources", ofType: "bundle") {
                let resourceBundle = NSBundle(path: path)
                let image = UIImage(named: "onepassword-navbar", inBundle: resourceBundle, compatibleWithTraitCollection: nil)

                navigationItem.rightBarButtonItem = UIBarButtonItem(image: image,
                    style: .Plain, target: self, action: "buttonOnePasswordPressed:")
            }
        }

        //Left button is a Cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel,
            target: self, action: "buttonCancelPressed:")
        #endif
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Actions
    ////////////////////////////////////////////////////////////////////////////

    #if os(iOS)
    @objc private func buttonCancelPressed(sender: AnyObject) {
        onDismiss?(nil)
        dismissViewControllerAnimated(true, completion: nil)
    }

    @objc private func buttonOnePasswordPressed(sender: AnyObject) {
        if OnePasswordExtension.sharedExtension().isAppExtensionAvailable() {
            OnePasswordExtension.sharedExtension().fillItemIntoWebView(webView,
                forViewController: self,
                sender: sender,
                showOnlyLogins: true,
                completion: nil)
        }
    }
    #endif

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Properties
    ////////////////////////////////////////////////////////////////////////////

    var URL: NSURL? {
        get {
            return URLRequest?.URL
        }
        set {
            if let URL = newValue {
                URLRequest = NSURLRequest(URL: URL)
            }
            else {
                URLRequest = nil
            }
        }
    }

    var URLRequest: NSURLRequest? {
        didSet {
            if let URLRequest = URLRequest {
                webView.loadRequest(URLRequest)
            }
            else {
                webView.loadHTMLString("", baseURL: nil)
            }
        }
    }

    var autoDismissScheme: String?

    var onDismiss: (NSURL? -> Void)?

    ////////////////////////////////////////////////////////////////////////////


    // MARK: WKNavigationDelegate
    ////////////////////////////////////////////////////////////////////////////

    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.URL?.scheme == autoDismissScheme {
            decisionHandler(.Cancel)

            onDismiss?(navigationAction.request.URL)
            #if os(OSX)
                dismissViewController(self)
            #else
                dismissViewControllerAnimated(true, completion: nil)
            #endif
        }
        else {
            decisionHandler(.Allow)
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
