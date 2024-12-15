import sqlite3
import json
import sys

def fetch_participants(db_path):
    try:
        connection = sqlite3.connect(db_path)
        cursor = connection.cursor()
        
        cursor.execute("SELECT DISTINCT id FROM handle")
        rows = cursor.fetchall()
        participants = [row[0] for row in rows if row[0] is not None]
        
        print(json.dumps(participants), flush=True)
    except sqlite3.Error as e:
        print(json.dumps({"error": str(e)}), flush=True)
    finally:
        if connection:
            connection.close()

def fetch_messages(db_path, participant):
    try:
        connection = sqlite3.connect(db_path)
        cursor = connection.cursor()
        
        cursor.execute("""
            SELECT message.text 
            FROM message
            JOIN handle ON message.handle_id = handle.ROWID
            WHERE handle.id = ? AND message.text IS NOT NULL
        """, (participant,))
        rows = cursor.fetchall()
        messages = [row[0] for row in rows]
        
        print(json.dumps(messages), flush=True)
    except sqlite3.Error as e:
        print(json.dumps({"error": str(e)}), flush=True)
    finally:
        if connection:
            connection.close()

if __name__ == "__main__":
    db_path = sys.argv[1]
    action = sys.argv[2]
    
    if action == "participants":
        fetch_participants(db_path)
    elif action == "messages" and len(sys.argv) > 3:
        participant = sys.argv[3]
        fetch_messages(db_path, participant)
    else:
        print(json.dumps({"error": "Invalid arguments"}), flush=True)
