"""
verify.py

Runs every query in queries.sql against chinook.db and prints the
results. Useful for checking your environment is set up correctly,
or for seeing the output of each question without opening a separate
SQL client.

Usage:
    python3 verify.py
"""

import sqlite3
import re
import sys

DB_PATH = "chinook.db"
SQL_PATH = "queries.sql"


def load_queries(path):
    """Split queries.sql into (label, sql) pairs using the Q<N>. comments."""
    with open(path, "r") as f:
        content = f.read()

    # Each query is preceded by a comment block containing "Qn."
    pattern = re.compile(r"Q(\d+)\.\s+(.*?)\n.*?---+\s*\*/\s*(SELECT.*?;)", re.S)
    matches = pattern.findall(content)

    queries = []
    for num, question_text, sql in matches:
        question = question_text.strip().split("\n")[0]
        queries.append((f"Q{num}", question, sql.strip()))
    return queries


def main():
    try:
        conn = sqlite3.connect(DB_PATH)
    except sqlite3.Error as e:
        print(f"Could not open {DB_PATH}: {e}")
        sys.exit(1)

    cur = conn.cursor()
    queries = load_queries(SQL_PATH)

    if not queries:
        print("No queries found. Check that queries.sql is present and unmodified.")
        sys.exit(1)

    for label, question, sql in queries:
        print(f"\n{label}: {question}")
        print("-" * 70)
        try:
            cur.execute(sql)
            cols = [d[0] for d in cur.description]
            rows = cur.fetchall()
            print(" | ".join(cols))
            for row in rows:
                print(" | ".join(str(v) for v in row))
            if not rows:
                print("(no rows returned)")
        except sqlite3.Error as e:
            print(f"ERROR running query: {e}")

    conn.close()


if __name__ == "__main__":
    main()
