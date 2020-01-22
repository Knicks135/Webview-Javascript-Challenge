//
//  MainVC.swift
//  JumboPrivacy-test
//
//  Created by David Shi on 1/19/20.
//  Copyright © 2020 David Shi. All rights reserved.
//

import UIKit
import WebKit

class MainVC: UIViewController, WebViewHandlerDelegate, UITableViewDataSource {
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var operationsStatusTableView: UITableView!
    @IBOutlet weak var startOperationsButton: UIButton!
    
    private var webViewHandler: WebViewHandler?
    var pageLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStartOperationsButton()
        createWebView()
        initializeWebView()
        setupOperationsTableView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func setupStartOperationsButton() {
        startOperationsButton.isHidden = true
        startOperationsButton.layer.cornerRadius = 10
    }

    private func createWebView() {
        let webViewHandler = WebViewHandler()
        webViewHandler.webView.frame = webViewContainer.frame
        webViewHandler.delegate = self
        webViewContainer.addSubview(webViewHandler.webView)
        self.webViewHandler = webViewHandler
    }
    
    private func setupOperationsTableView() {
        operationsStatusTableView.dataSource = self
        operationsStatusTableView.register(UINib(nibName: OperationTableViewCell.cellId, bundle: nil), forCellReuseIdentifier: OperationTableViewCell.cellId)
    }
    
    private func initializeWebView() {
        guard let webView = webViewHandler else {
            print("Webview handler doesn't exist during initialization")
            return
        }
        webView.loadPage()
    }
    
    @IBAction func startOperationsButtonTapped(_ sender: UIButton) {
        guard let webView = webViewHandler else {
            print("Webview handler doesn't exist during initialization")
            return
        }
        let id = String(OperationService.shared.generatedNextId())
        webView.startOperation(withId: id)
    }
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        OperationService.shared.operationQueue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OperationTableViewCell.cellId, for: indexPath) as? OperationTableViewCell else {
            print("Unable to initialize OperationTableViewCell")
            return UITableViewCell()
        }
        let messageData = OperationService.shared.operationQueue[indexPath.row]
        
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                cell.configureCell(withMessageData: messageData)
            }
        } else {
            cell.configureCell(withMessageData: messageData)
        }
        
        return cell
    }
        
    //MARK:- WebViewHandlerDelegate
    func pageFinishedLoading() {
        startOperationsButton.isHidden = false
        pageLoaded = true
    }
    
    func didReceiveMessage(message: String) {
        do {
            let data = Data(message.utf8)
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                guard let id = dict["id"] as? String else {
                    print("There was no id key")
                    return
                }
                
                //If a new operation is started, create a new MessageData object, otherwise modify the existing one corresponding to the id.
                guard let messageDataIndex = OperationService.shared.operationQueue.firstIndex(where: {$0.id == id}) else {
                    OperationService.shared.parseMessageHandlerData(forNew: dict) { [weak self] (result) in
                        switch result {
                        case .success(_):
                            self?.operationsStatusTableView.reloadData()
                        case .failure(let error):
                            switch error{
                            case .parsingError:
                                print("There was an error parsing the MessageData")
                            }
                        }
                        
                    }
                    return
                }
                
                OperationService.shared.parseMessageHandlerData(forExisting: dict, atIndex: messageDataIndex) { [weak self] (result) in
                    switch result {
                    case .success(_):
                        self?.operationsStatusTableView.updateRow(row: messageDataIndex)
                    case .failure(let error):
                        switch error{
                        case .parsingError:
                            print("There was an error parsing the MessageData")
                        }
                    }
                }
                
            }
        } catch let error {
            print("There was an error serializing JSON object from incoming message, error: \(error.localizedDescription)")
        }
    }
}
