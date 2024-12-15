//
//  ContentView.swift
//  iMessageExplorer
//
//  Created by Raqeeb Anjum on 12/14/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var participantNames: [String] = []
    @State private var folderURL: URL?

    var body: some View {
        VStack {
            Text("Participants")
                .font(.headline)
            
            if participantNames.isEmpty {
                Text("No participants found")
                    .foregroundColor(.gray)
            } else {
                List(participantNames, id: \.self) { name in
                    Text(name)
                }
            }
            
            Button("Select Folder") {
                selectFolder()
            }
            .padding()
        }
    }
    
    /// Folder picker using NSOpenPanel
    func selectFolder() {
        let panel = NSOpenPanel()
        panel.title = "Choose the iMessage folder"
        panel.allowedContentTypes = [UTType.folder]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false

        if panel.runModal() == .OK, let selectedFolder = panel.url {
            folderURL = selectedFolder
            fetchParticipantNames(from: selectedFolder)
        }
    }

    /// Fetch participant names using the Python script
    func fetchParticipantNames(from folder: URL) {
        let pythonScript = Bundle.main.path(forResource: "database_helper", ofType: "py")!
        let dbPath = folder.appendingPathComponent("chat.db").path

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process.arguments = [pythonScript, dbPath]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8),
               let jsonData = output.data(using: .utf8),
               let names = try? JSONDecoder().decode([String].self, from: jsonData) {
                DispatchQueue.main.async {
                    participantNames = names
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
