//
//  ContentView.swift
//  iMessageExplorer
//
//  Created by Raqeeb Anjum on 12/14/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedFolder: URL?
    @State private var messages: [Message] = []

    var body: some View {
        VStack {
            Text("iMessageExplorer")
                .font(.largeTitle)
                .padding()

            if let folder = selectedFolder {
                Text("Selected Folder: \(folder.path)")
                    .foregroundColor(.green)
                    .padding()
            } else {
                Text("No folder selected")
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: selectFolder) {
                Text("Select Messages Folder")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            if !messages.isEmpty {
                List(messages) { message in
                    MessageBubbleView(message: message)
                }
            } else {
                Text("No messages loaded")
                    .padding()
            }
        }
        .frame(width: 400, height: 600)
    }

    func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.title = "Select Messages Folder"

        if panel.runModal() == .OK, let folderURL = panel.url {
            // Check if chat.db exists in the selected folder
            let chatDbPath = folderURL.appendingPathComponent("chat.db")
            
            if FileManager.default.fileExists(atPath: chatDbPath.path) {
                selectedFolder = folderURL
                messages = DatabaseHelper.fetchMessages(from: folderURL)
                
                print("Selected folder: \(folderURL.path)")
                print("Loaded \(messages.count) messages")
            } else {
                // Alert the user that no chat.db was found
                let alert = NSAlert()
                alert.messageText = "No chat.db found"
                alert.informativeText = "Please select the folder containing the chat.db file."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
    }
}

#Preview {
    ContentView()
}
