import sqlite3
import json
import sys

# Fetch participant names from the database
def fetch_participant_names(db_path):
    try:
        connection = sqlite3.connect(db_path)
        cursor = connection.cursor()
        
        # Fetch unique names from the 'handle' table
        cursor.execute("SELECT DISTINCT id FROM handle")
        rows = cursor.fetchall()
        
        # Convert rows to a list of strings
        names = [row[0] for row in rows if row[0] is not None]
        
        # Return the data as JSON
        print(json.dumps(names))
        
    except sqlite3.Error as e:
        print(json.dumps({"error": str(e)}))
    finally:
        if connection:
            connection.close()

# Entry point: first argument is the database path
if __name__ == "__main__":
    db_path = sys.argv[1]  # Path to chat.db
    fetch_participant_names(db_path)
