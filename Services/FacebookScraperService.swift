//
//  FacebookScraperService.swift
//  PureFB
//
//  Created by iOS Engineer on [CURRENT_DATE].
//

import WebKit
import Foundation

class LeakAvoiderProxy: NSObject, WKScriptMessageHandler {
    weak var delegate: FacebookScraperService?

    init(delegate: FacebookScraperService) {
        self.delegate = delegate
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

class FacebookScraperService: NSObject, WKScriptMessageHandler {
    private var webView: WKWebView!
    private var leakAvoiderProxy: LeakAvoiderProxy!

    override init() {
        super.init()
        let contentController = WKUserContentController()
        leakAvoiderProxy = LeakAvoiderProxy(delegate: self)
        contentController.add(leakAvoiderProxy, name: "pureFBBridge")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        webView = WKWebView(frame: .zero, configuration: config)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let jsonString = message.body as? String {
            print("Received JSON from JavaScript: \\(jsonString)")
        }
    }

    private func jsInjectionScript() -> String {
        return """
        (function() {
            const posts = [];
            document.querySelectorAll('[data-pagelet="FeedUnit"]').forEach(postElement => {
                const text = postElement.querySelector('div[data-ad-preview="message"]')?.innerText;
                const imageUrl = postElement.querySelector('img')?.src;
                const timestamp = postElement.querySelector('abbr')?.getAttribute('title');

                if (text || imageUrl || timestamp) {
                    posts.push({ text, imageUrl, timestamp });
                }
            });

            window.webkit.messageHandlers.pureFBBridge.postMessage(JSON.stringify(posts));
        })();
        """
    }

    func startScraping() {
        // Load a Facebook page or URL here
        let url = URL(string: "https://www.facebook.com")!
        webView.load(URLRequest(url: url))

        // Inject the JavaScript after the page has loaded
        webView.evaluateJavaScript(jsInjectionScript(), completionHandler: nil)
    }

    func scrape(url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let validURL = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        webView.load(URLRequest(url: validURL))

        webView.evaluateJavaScript(jsInjectionScript()) { (result, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let jsonString = result as? String else {
                completion(.failure(NSError(domain: "Invalid JSON", code: -1, userInfo: nil)))
                return
            }

            if let jsonData = jsonString.data(using: .utf8) {
                completion(.success(jsonData))
            } else {
                completion(.failure(NSError(domain: "Failed to convert string to data", code: -1, userInfo: nil)))
            }
        }
    }
}

