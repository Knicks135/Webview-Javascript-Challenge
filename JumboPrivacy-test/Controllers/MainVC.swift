//
//  MainVC.swift
//  JumboPrivacy-test
//
//  Created by David Shi on 1/19/20.
//  Copyright © 2020 David Shi. All rights reserved.
//

import UIKit
import WebKit

class MainVC: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
   
    var webView: WKWebView?
    var siteFinishedLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .blue
        
        addScriptMessagesHandler()
        loadPage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       
//        OperationService.shared.initializeJSContext()
//        OperationService.shared.initializeMessageHandler()
//        OperationService.shared.startOperation()
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
    
    func addScriptMessagesHandler() {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        guard let script = loadJsScript() else { return }
        let wkScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(wkScript)
        userContentController.add(self, name: "jumbo")

        config.userContentController = userContentController

        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        self.webView?.navigationDelegate = self
        self.view = self.webView
    }
    
    func loadPage() {
        guard let jumboUrl = URL(string: "https://blog.jumboprivacy.com/") else {
            print("URL for jumbo cannot be made")
            return
        }
        webView?.load(URLRequest(url: jumboUrl))
    }
    
    @objc func handleIncomingMessage(notification: Notification) {
        if let jsonString = notification.object as? String {
            do {
                let data = Data(jsonString.utf8)
                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    guard let id = dict["id"] as? String else {
                        print("There was no id key")
                        return
                    }
                    
                    guard let messageDataIndex = OperationService.shared.operationQueue.firstIndex(where: {$0.id == id}) else {
                        OperationService.shared.parseMessageHandlerData(forNew: dict)
                        return
                    }
                    
                    OperationService.shared.parseMessageHandlerData(forExisting: dict, atIndex: messageDataIndex)
                    
                }
            } catch let error {
                print("There was an error serializing JSON object from incoming message, error: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK:- WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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
