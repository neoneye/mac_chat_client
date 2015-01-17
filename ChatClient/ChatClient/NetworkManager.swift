//
//  NetworkManager.swift
//  ChatClient
//
//  Created by Simon Strandgaard on 17-01-15.
//  Copyright (c) 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

enum NetworkManagerResult {
	case Success(data: NSData)
	case Failure(error: NSError)
}

class NetworkManager: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
	class var sharedInstance : NetworkManager {
		struct Static {
			static let instance : NetworkManager = NetworkManager()
		}
		return Static.instance
	}
	
	var session: NSURLSession!
	
	override init() {
		super.init()
		
		self.session = NSURLSession(
			configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
			delegate: self,
			delegateQueue: NSOperationQueue.mainQueue()
		)
	}
	
	func execute(request: NSURLRequest, callback: (result: NetworkManagerResult) -> Void) {
		var task = session.dataTaskWithRequest(request) {
			(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
			if error != nil {
				callback(result: .Failure(error: error))
			} else {
				callback(result: .Success(data: data))
			}
		}
		task.resume()
	}
	

	func URLSession(session: NSURLSession,
		didReceiveChallenge challenge: NSURLAuthenticationChallenge,
		completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
			
		completionHandler(
			NSURLSessionAuthChallengeDisposition.UseCredential,
			NSURLCredential(forTrust: challenge.protectionSpace.serverTrust)
		)
	}
	
	func URLSession(session: NSURLSession,
		task: NSURLSessionTask,
		willPerformHTTPRedirection response: NSHTTPURLResponse,
		newRequest request: NSURLRequest,
		completionHandler: (NSURLRequest!) -> Void) {
			
		let newRequest : NSURLRequest? = request
		println(newRequest?.description);
		completionHandler(newRequest)
	}

}
