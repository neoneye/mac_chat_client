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
		
		serverTextField.placeholderString = "https://localhost:8334/graph/123/command"
		serverTextField.target = self
		serverTextField.action = Selector("serverTextFieldAction")
		
		if ServerSettings.sharedInstance.server.isEmpty {
			ServerSettings.sharedInstance.server = "https://localhost:8334/graph/123/command"
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
		var dict = Dictionary<String, AnyObject>()
		dict["command"] = text
		
		// convert dictionary to json data
		var error: NSError?
		let data = NSJSONSerialization.dataWithJSONObject(dict, options: nil, error: &error)
		if let error = error {
			showFailure(error)
			return
		}
		if data == nil {
			showReply("could not serialize to json")
			return
		}
		
		// create a POST request
		let server = ServerSettings.sharedInstance.server
		let url: NSURL! = NSURL(string: server)
		if url == nil {
			println("error invalid url \(url)")
			showReply("error invalid url \(url)")
			return
		}
		let request = NSMutableURLRequest(URL: url!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 15)
		request.HTTPMethod = "POST"
		request.HTTPBody = data
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")

		// execute the POST request
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

