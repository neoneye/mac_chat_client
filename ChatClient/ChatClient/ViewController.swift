//
//  ViewController.swift
//  ChatClient
//
//  Created by Simon Strandgaard on 09-01-15.
//  Copyright (c) 2015 Simon Strandgaard. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
	@IBOutlet var serverTextField: NSTextField!
	@IBOutlet var historyTextView: NSTextView!
	@IBOutlet var messageTextField: NSTextField!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		serverTextField.placeholderString = "http://localhost:1234/"
		serverTextField.target = self
		serverTextField.action = Selector("serverTextFieldAction")
		
		if ServerSettings.sharedInstance.server.isEmpty {
			ServerSettings.sharedInstance.server = "http://localhost:1234/"
		}
		let server = ServerSettings.sharedInstance.server
		if !server.isEmpty {
			serverTextField.stringValue = server
		}

		messageTextField.target = self
		messageTextField.action = Selector("messageTextFieldAction")
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		messageTextField.becomeFirstResponder()
	}

	func serverTextFieldAction() {
		let text = serverTextField.stringValue
		println("server: \(text)")
		ServerSettings.sharedInstance.server = text
	}
	
	func messageTextFieldAction() {
		let text = messageTextField.stringValue
		if text.isEmpty {
			return
		}
		println("request:  \(text)")
		
		let appendText = "\(text)\n"
		historyTextView.appendBold(appendText)
		
		weak var weakSelf = self
		dispatch_async(dispatch_get_main_queue()) {
			if let s = weakSelf {
				s.sendText(text)
			}
		}
	}
	
	func showReply(replyText: String) {
		let appendText = "\(replyText)\n\n"
		historyTextView.append(appendText)
	}

	func sendText(text: String) {
		let server = ServerSettings.sharedInstance.server
		let endpoint: NSURL! = NSURL(string: server)
		let urlComponents = NSURLComponents(URL: endpoint, resolvingAgainstBaseURL: false)
		urlComponents?.path = "/chat"
		urlComponents?.query = "message=" + text.urlEncode()
		let url: NSURL? = urlComponents?.URL
		if url == nil {
			println("error invalid url \(url)")
			showReply("error invalid url \(url)")
			return
		}
		let request = NSURLRequest(URL: url!)

		NetworkManager.sharedInstance.execute(request) { (result: NetworkManagerResult) -> Void in
			switch result {
			case let .Success(data):
				self.showSuccessData(data)
			case let .Failure(error):
				self.showFailure(error)
			}
		}
	}

	func showSuccessData(data: NSData) {
		let responseTextOrNil: String? = NSString(data: data, encoding: NSUTF8StringEncoding)
		if responseTextOrNil == nil {
			println("error response data is not utf8")
			showReply("error response data is not utf8")
			return
		}
		
		let responseText: String = responseTextOrNil!
		println("response: \(responseText)")
		showReply(responseText)
	}

	func showFailure(error: NSError) {
		let responseText: String = error.localizedDescription
		println("response: \(responseText)")
		showReply(responseText)
	}

}

