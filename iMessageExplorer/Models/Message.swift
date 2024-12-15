//
//  Message.swift
//  iMessageExplorer
//
//  Created by Raqeeb Anjum on 12/14/24.
//

import Foundation

struct Message: Identifiable {
    let id: Int
    let text: String
    let timestamp: Date
    let isFromMe: Bool
}
