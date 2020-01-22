//
//  WebViewHandler.swift
//  JumboPrivacy-test
//
//  Created by David Shi on 1/22/20.
//  Copyright © 2020 David Shi. All rights reserved.
//

import Foundation
import WebKit

/// Implement this protocol to be notified about messages received by the WebView
/// via postMessage
protocol WebViewHandlerDelegate {
    /// Called when a message is received by the WebView
    /// - Parameter message: the message received
    func didReceiveMessage(message:Any)
    func pageFinishedLoading()
}

final class WebViewHandler: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView
    var delegate: WebViewHandlerDelegate?
    
    override init() {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        self.webView = WKWebView()
        super.init()
        guard let script = loadJsScript() else { return }
        let wkScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(wkScript)
        userContentController.add(self, name: "jumbo")

        config.userContentController = userContentController
        
        //Updated config must be loaded with the script and message handler to receive updates
        self.webView = WKWebView(frame: .zero, configuration: config)
        self.webView.navigationDelegate = self
    }
    
    func loadJsScript() -> String? {
        do {
            guard let scriptUrl = URL(string: "https://jumboassetsv1.blob.core.windows.net/publicfiles/interview_bundle.js") else {
                print("Couldn't load URL for script")
                return nil
            }
            let interviewScript = try String(contentsOf: scriptUrl,
                                             encoding: String.Encoding.utf8)
            return interviewScript
        } catch let error {
            print("Error while processing script file: \(error)")
            return nil
        }
    }
    
    func loadPage() {
        guard let jumboUrl = URL(string: "https://blog.jumboprivacy.com/") else {
            print("URL for jumbo cannot be made")
            return
        }
        webView.load(URLRequest(url: jumboUrl))
    }
    
    //MARK:- WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.pageFinishedLoading()
        let id = "1"
        let execString = "startOperation('\(id)')"
        webView.evaluateJavaScript(execString) { (result, error) in
            guard error == nil, let result = result else {
                print("Error!")
                return
            }
            print(result)
        }
    }
    
    //MARK:- WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "jumbo", let messageBody = message.body as? String {
            print(messageBody)
        }
    }
}
