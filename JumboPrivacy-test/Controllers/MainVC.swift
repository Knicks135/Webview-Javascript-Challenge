//
//  MainVC.swift
//  JumboPrivacy-test
//
//  Created by David Shi on 1/19/20.
//  Copyright © 2020 David Shi. All rights reserved.
//

import UIKit
import WebKit

class MainVC: UIViewController {
   
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var operationsStatusTableView: UITableView!
    @IBOutlet weak var startOperationsButton: UIButton!
    
    private var webViewHandler: WebViewHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
        createWebView()
        initializeWebView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    func createWebView() {
        let webViewHandler = WebViewHandler()
        webViewHandler.webView.frame = webViewContainer.frame
        webViewContainer.addSubview(webViewHandler.webView)
        self.webViewHandler = webViewHandler
    }
    
    func initializeWebView() {
        guard let webView = webViewHandler else {
            print("Webview handler doesn't exist during initialization")
            return
        }
        webView.loadPage()
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
}
