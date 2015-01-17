//
//  ServerSettings.swift
//  ChatClient
//
//  Created by Simon Strandgaard on 10-01-15.
//  Copyright (c) 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

class ServerSettings {
	class var sharedInstance : ServerSettings {
		struct Static {
			static let instance : ServerSettings = ServerSettings()
		}
		return Static.instance
	}
	
	var server: String {
		get {
			var returnValue: String? = NSUserDefaults.standardUserDefaults().objectForKey("the-server") as? String
			if returnValue == nil {
				returnValue = "http://localhost/"
			}
			return returnValue!
		}
		set (newValue) {
			NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "the-server")
			NSUserDefaults.standardUserDefaults().synchronize()
		}
	}
}