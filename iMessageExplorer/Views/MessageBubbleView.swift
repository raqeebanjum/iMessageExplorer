//
//  MessageBubbleView.swift
//  iMessageExplorer
//
//  Created by Raqeeb Anjum on 12/14/24.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message

    var body: some View {
        VStack(alignment: message.isFromMe ? .trailing : .leading) {
            HStack {
                if message.isFromMe { Spacer() }
                Text(message.text)
                    .padding()
                    .background(message.isFromMe ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                if !message.isFromMe { Spacer() }
            }
            Text(message.timestamp, style: .time) // Display the time
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(message.isFromMe ? .leading : .trailing, 50)
        .padding(.vertical, 5)
    }
}
