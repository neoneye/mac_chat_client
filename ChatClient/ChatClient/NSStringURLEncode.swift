//
//  NSStringURLEncode.swift
//  ChatClient
//
//  Created by Simon Strandgaard on 09-01-15.
//  Copyright (c) 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

extension String {
	func urlEncode() -> String {
		return CFURLCreateStringByAddingPercentEscapes(
			nil,
			self,
			nil,
			"!*'();:@&=+$,/?%#[]",
			CFStringBuiltInEncodings.UTF8.rawValue
		)
	}
}