//
//  NSTextFieldExtension.swift
//  ChatClient
//
//  Created by Simon Strandgaard on 09-01-15.
//  Copyright (c) 2015 Simon Strandgaard. All rights reserved.
//

import Cocoa

extension NSTextView {
	func append(string: String) {
		styledAppend(string, bold: false)
	}
	
	func appendBold(string: String) {
		styledAppend(string, bold: true)
	}
	
	func styledAppend(string: String, bold: Bool) {
		var font: NSFont!
		if bold {
			font = NSFont.boldSystemFontOfSize(28)
		} else {
			font = NSFont.systemFontOfSize(28)
		}
		let attributes = [NSFontAttributeName: font]
		let attributedString = NSAttributedString(string: string, attributes:attributes)
		
		self.textStorage?.appendAttributedString(attributedString)
		self.scrollToEndOfDocument(nil)
	}
}