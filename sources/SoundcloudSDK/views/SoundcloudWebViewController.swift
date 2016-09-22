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

class SoundcloudWebViewController: ViewController, WKNavigationDelegate {
    fileprivate lazy var webView = WKWebView()

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
        if OnePasswordExtension.shared().isAppExtensionAvailable() {
            let bundle = Bundle(for: OnePasswordExtension.self)
            if let path = bundle.path(forResource: "OnePasswordExtensionResources", ofType: "bundle") {
                let resourceBundle = Bundle(path: path)
                let image = UIImage(
                    named: "onepassword-navbar", in: resourceBundle,
                    compatibleWith: nil)

                navigationItem.rightBarButtonItem = UIBarButtonItem(
                    image: image, style: .plain, target: self,
                    action: #selector(SoundcloudWebViewController.buttonOnePasswordPressed))
            }
        }

        //Left button is a Cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self,
            action: #selector(SoundcloudWebViewController.buttonCancelPressed(_:)))
        #endif
    }

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Actions
    ////////////////////////////////////////////////////////////////////////////

    #if os(iOS)
    @objc fileprivate func buttonCancelPressed(_: AnyObject) {
        onDismiss?(nil)
        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func buttonOnePasswordPressed(_ sender: AnyObject) {
        if OnePasswordExtension.shared().isAppExtensionAvailable() {
            OnePasswordExtension.shared().fillItem(
                intoWebView: webView,
                for: self,
                sender: sender,
                showOnlyLogins: true,
                completion: nil)
        }
    }
    #endif

    ////////////////////////////////////////////////////////////////////////////


    // MARK: Properties
    ////////////////////////////////////////////////////////////////////////////

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

    var autoDismissScheme: String?

    var onDismiss: ((URL?) -> Void)?

    ////////////////////////////////////////////////////////////////////////////


    // MARK: WKNavigationDelegate
    ////////////////////////////////////////////////////////////////////////////

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.scheme == autoDismissScheme {
            decisionHandler(.cancel)
            
            onDismiss?(navigationAction.request.url)
            #if os(OSX)
                dismissViewController(self)
            #else
                dismiss(animated: true, completion: nil)
            #endif
        }
        else {
            decisionHandler(.allow)
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////
}
