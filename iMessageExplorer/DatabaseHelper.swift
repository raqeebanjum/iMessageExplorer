//
//  DatabaseHelper.swift
//  iMessageExplorer
//
//  Created by Raqeeb Anjum on 12/14/24.
//

import SQLite
import Foundation

struct DatabaseHelper {
    static func fetchMessages(from folder: URL) -> [Message] {
        var messages = [Message]()
        
        let dbPath = folder.appendingPathComponent("chat.db").path
        
        guard FileManager.default.fileExists(atPath: dbPath) else {
            print("Database file does not exist at path: \(dbPath)")
            return messages
        }
        
        do {
            let db = try Connection(dbPath, readonly: true)
            
            #if DEBUG
            db.trace { print($0) }
            #endif
            
            let messageTable = Table("message")
            let id = Expression<Int64>("ROWID")
            let text = Expression<String?>("text")
            let isFromMe = Expression<Int64>("is_from_me")
            let date = Expression<Double>("date")
            
            // List available tables
            print("Checking available tables:")
            let tableNames = try db.scalar("SELECT name FROM sqlite_master WHERE type='table';") as? [String] ?? []
            for tableName in tableNames {
                print("Found table: \(tableName)")
            }
            
            let query = messageTable.order(date.asc)
            
            let rowCount = try db.scalar(query.count)
            print("Total rows in message table: \(rowCount)")
            
            let iterator = try db.prepare(query)
            
            for row in iterator {
                print("Raw row data:")
                print("ID: \(row[id])")
                print("Text: \(row[text] ?? "nil")")
                print("Is From Me: \(row[isFromMe])")
                print("Date: \(row[date])")

                let messageText = row[text] ?? "(No text)"
                let timestamp = Date(timeIntervalSince1970: row[date] + 978307200)
                let message = Message(
                    id: Int(row[id]),
                    text: messageText,
                    timestamp: timestamp,
                    isFromMe: row[isFromMe] == 1
                )
                messages.append(message)
            }
        } catch {
            print("Error details:")
            print("Error type: \(type(of: error))")
            print("Error description: \(error.localizedDescription)")
            print("Error: \(error)")
        }
        
        return messages
    }
}
