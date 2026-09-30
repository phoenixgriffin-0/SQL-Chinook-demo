# Learning SQL with Business Questions: The Chinook Database

This is a small, self-contained project for learning SQL by answering
real business questions against a sample database, instead of
learning syntax in the abstract.

## The Database

[Chinook](https://github.com/lerocha/chinook-database) is a free,
widely-used sample database that models a digital music store, similar
in spirit to an old iTunes catalog. It has customers, invoices,
employees, tracks, albums, artists, and genres, which makes it a
realistic stand-in for a small e-commerce or media business.

The database file (`chinook.db`) is included in this repo as a single
SQLite file, so no server setup is required.

## What's in this repo

| File | Purpose |
|---|---|
| `chinook.db` | The sample database (SQLite) |
| `queries.sql` | 10 business questions, each with a plain-English explanation, the SQL query, and a note on what SQL concept it introduces |
| `verify.py` | A small Python script that runs every query and prints the results, so you can check your setup works |
| `README.md` | This file |

## The 10 questions

The questions are ordered so each one introduces one new SQL concept
on top of the last:

1. **Total revenue and order count** — `SELECT`, aggregate functions
2. **Top 5 countries by revenue** — `GROUP BY`, `ORDER BY`, `LIMIT`
3. **Top 5 customers by spend** — `JOIN`
4. **Best-selling genres by units** — joining three tables
5. **Revenue generated per sales rep** — a three-table join across a
   one-to-many-to-many relationship
6. **Average order value by country** — `AVG()` vs `SUM()`
7. **Artists with the most tracks in the catalog** — a catalog-only
   query with no sales data involved
8. **Customers who haven't bought anything recently** — `HAVING`
   vs `WHERE`
9. **Revenue share by genre (%)** — a subquery inside `SELECT`
10. **Repeat vs one-time customers** — a subquery inside `FROM`
    (a derived table), plus `CASE WHEN`

Open `queries.sql` and read it top to bottom. Each query is preceded
by a comment block explaining the business question and the SQL idea
it introduces.

## Running it yourself

You need Python 3 (comes with the `sqlite3` module built in, no
install required).

```bash
git clone <this-repo-url>
cd <repo-folder>
python3 verify.py
```

This prints the results of all 10 queries to your terminal.

If you prefer a SQL client instead of the Python script:

```bash
sqlite3 chinook.db
.read queries.sql
```

or open `chinook.db` in any SQLite-compatible GUI tool (DB Browser
for SQLite, TablePlus, DBeaver, etc.) and paste in queries from
`queries.sql` one at a time.

## Next steps if you want to keep practicing

- Try changing the `LIMIT` values in each query and see how the
  results change.
- In Q10, change `invoice_count > 1` to a higher number and see how
  the definition of "repeat customer" shifts the split.
- Write an 11th question yourself, for example: "which media type
  (MP3, AAC, etc.) generates the most revenue?" The `MediaType` and
  `Track` tables have what you need.

## Credit

Chinook database created by Luis Rocha and contributors:
https://github.com/lerocha/chinook-database
