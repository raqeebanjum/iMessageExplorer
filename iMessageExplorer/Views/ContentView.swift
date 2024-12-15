//
//  ContentView.swift
//  iMessageExplorer
//
//  Created by Raqeeb Anjum on 12/14/24.
//

import SwiftUI

struct ContentView: View {
    @State private var folderURL: URL?
    @State private var participants: [String] = []
    @State private var messages: [String] = []
    @State private var selectedParticipant: String?

    var body: some View {
        VStack {
            // Folder Selection Button
            if folderURL == nil {
                Button("Select Folder") {
                    selectFolder()
                }
                .padding()
                .buttonStyle(BorderedProminentButtonStyle())
            } else {
                // Display Participants and Messages
                HStack {
                    // Participants List
                    List(participants, id: \.self, selection: $selectedParticipant) { participant in
                        Text(participant)
                            .onTapGesture {
                                selectedParticipant = participant
                                fetchMessages(for: participant)
                            }
                    }
                    .frame(minWidth: 200)
                    
                    // Messages View
                    if let participant = selectedParticipant {
                        List(messages, id: \.self) { message in
                            Text(message)
                                .padding(5)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Text("Select a participant to view messages")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
    }

    // Select Folder Function
    func selectFolder() {
        let panel = NSOpenPanel()
        panel.title = "Choose the iMessage folder"
        panel.allowedContentTypes = [.folder]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false

        if panel.runModal() == .OK, let selectedFolder = panel.url {
            folderURL = selectedFolder
            fetchParticipants(from: selectedFolder)
        }
    }

    // Fetch Participants
    func fetchParticipants(from folder: URL) {
        let pythonScript = Bundle.main.path(forResource: "database_helper", ofType: "py")!
        let dbPath = folder.appendingPathComponent("chat.db").path

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process.arguments = [pythonScript, dbPath, "participants"]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8),
               let jsonData = output.data(using: .utf8),
               let fetchedParticipants = try? JSONDecoder().decode([String].self, from: jsonData) {
                DispatchQueue.main.async {
                    self.participants = fetchedParticipants.sorted()
                }
            }
        } catch {
            print("Error running Python script: \(error)")
        }
    }

    // Fetch Messages for Selected Participant
    func fetchMessages(for participant: String) {
        let pythonScript = Bundle.main.path(forResource: "database_helper", ofType: "py")!
        let dbPath = folderURL!.appendingPathComponent("chat.db").path

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process.arguments = [pythonScript, dbPath, "messages", participant]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8),
               let jsonData = output.data(using: .utf8),
               let fetchedMessages = try? JSONDecoder().decode([String].self, from: jsonData) {
                DispatchQueue.main.async {
                    self.messages = fetchedMessages
                }
            }
        } catch {
            print("Error running Python script: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
