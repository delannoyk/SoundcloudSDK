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
import Foundation

class SoundcloudWebViewController: ViewController, WKNavigationDelegate {
    private lazy var webView = WKWebView()

    // MARK: View loading

    override func loadView() {
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        #if os(iOS)
        //Right button is OnePassword if available
        if OnePasswordExtension.shared().isAppExtensionAvailable() {
            let bundle = Bundle(for: OnePasswordExtension.self)
            if let path = bundle.path(forResource: "OnePasswordExtensionResources", ofType: "bundle") {
                let resourceBundle = Bundle(path: path)
                let image = UIImage(
                    named: "onepassword-navbar",
                    in: resourceBundle,
                    compatibleWith: nil)

                navigationItem.rightBarButtonItem = UIBarButtonItem(
                    image: image, style: .plain, target: self,
                    action: #selector(SoundcloudWebViewController.buttonOnePasswordPressed(sender:)))
            }
        }

        //Left button is a Cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self,
            action: #selector(SoundcloudWebViewController.buttonCancelPressed(sender:)))
        #endif
    }

    // MARK: Actions

    #if os(iOS)
    @objc private func buttonCancelPressed(sender: AnyObject) {
        onDismiss?(nil)
        dismiss(animated: true, completion: nil)
    }

    @objc private func buttonOnePasswordPressed(sender: AnyObject) {
        if OnePasswordExtension.shared().isAppExtensionAvailable() {
            OnePasswordExtension.shared().fillItem(
                intoWebView: webView,
                for: self,
                sender: sender,
                showOnlyLogins: true) { success, error in }
        }
    }
    #endif

    // MARK: Properties

    var url: URL? {
        get {
            return urlRequest?.url
        }
        set {
            if let url = newValue {
                urlRequest = URLRequest(url: url)
            }
            else {
                urlRequest = nil
            }
        }
    }

    var urlRequest: URLRequest? {
        didSet {
            if let urlRequest = urlRequest {
                webView.load(urlRequest)
            }
            else {
                webView.loadHTMLString("", baseURL: nil)
            }
        }
    }

    var autoDismissURI: String?

    var onDismiss: ((URL?) -> Void)?

    // MARK: Dismiss utils

    private func shouldDismiss(on url: URL?) -> Bool {
        return autoDismissURI.flatMap { url?.absoluteString.hasPrefix($0) } ?? false
    }

    // MARK: WKNavigationDelegate

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if shouldDismiss(on: navigationAction.request.url) {
            decisionHandler(.cancel)

            onDismiss?(navigationAction.request.url)
            #if os(OSX)
                dismissViewController(self)
            #else
                dismiss(animated: true, completion: nil)
            #endif
        } else {
            decisionHandler(.allow)
        }
    }
}
