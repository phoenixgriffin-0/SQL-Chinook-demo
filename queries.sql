/* =====================================================================
   10 BUSINESS QUESTIONS, ANSWERED IN SQL
   Database: Chinook (a sample digital music store)
   Tables used: Customer, Invoice, InvoiceLine, Track, Album, Artist,
                Genre, Employee

   How to use this file:
   Each question below is self-contained. Read the comment, then the
   query, then the "what's new here" note. Run them in order if you
   are learning SQL for the first time, since each one builds on the
   last. Run them against chinook.db with any SQLite client, or with
   the included verify.py script.
   ===================================================================== */


/* ---------------------------------------------------------------------
   Q1. How much total revenue have we made, and from how many orders?
   ---------------------------------------------------------------------
   This is the simplest possible business question: a single number.
   New concepts: SELECT, aggregate functions (COUNT, SUM), aliasing
   with AS, and ROUND() to keep currency values readable.
   --------------------------------------------------------------------- */
SELECT
    COUNT(*)          AS total_invoices,
    ROUND(SUM(Total), 2) AS total_revenue
FROM Invoice;


/* ---------------------------------------------------------------------
   Q2. Which 5 countries bring in the most revenue?
   ---------------------------------------------------------------------
   Now we go from "one number" to "one number per group."
   New concepts: GROUP BY (bucket rows by a column before aggregating),
   ORDER BY (sort the result), LIMIT (only show the top N rows).
   --------------------------------------------------------------------- */
SELECT
    BillingCountry,
    ROUND(SUM(Total), 2) AS revenue
FROM Invoice
GROUP BY BillingCountry
ORDER BY revenue DESC
LIMIT 5;


/* ---------------------------------------------------------------------
   Q3. Who are our top 5 customers by total spend?
   ---------------------------------------------------------------------
   Revenue lives on Invoice, but customer names live on Customer.
   We need both tables at once.
   New concepts: JOIN (combine two tables using a shared key),
   string concatenation with ||.
   --------------------------------------------------------------------- */
SELECT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS customer_name,
    ROUND(SUM(i.Total), 2) AS total_spent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY total_spent DESC
LIMIT 5;


/* ---------------------------------------------------------------------
   Q4. Which music genres sell the most units?
   ---------------------------------------------------------------------
   The genre of a track, and how many were sold, live in different
   tables three steps apart: Genre -> Track -> InvoiceLine.
   New concepts: joining THREE tables in one query, and the
   difference between SUM(Total) (revenue) and SUM(Quantity) (volume).
   --------------------------------------------------------------------- */
SELECT
    g.Name AS genre,
    SUM(il.Quantity) AS units_sold
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY units_sold DESC
LIMIT 5;


/* ---------------------------------------------------------------------
   Q5. Which sales rep (employee) has generated the most revenue
       through the customers they support?
   ---------------------------------------------------------------------
   This chains a relationship: an Employee supports Customers, and
   Customers create Invoices. So we join Employee -> Customer -> Invoice.
   New concept: a JOIN chain that follows a one-to-many-to-many
   relationship across three tables, not just three tables joined on
   the same key.
   --------------------------------------------------------------------- */
SELECT
    e.FirstName || ' ' || e.LastName AS employee,
    ROUND(SUM(i.Total), 2) AS revenue_generated
FROM Employee e
JOIN Customer c ON e.EmployeeId = c.SupportRepId
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY e.EmployeeId
ORDER BY revenue_generated DESC;


/* ---------------------------------------------------------------------
   Q6. Which countries have the highest AVERAGE order value
       (not just total revenue)?
   ---------------------------------------------------------------------
   A country could have high total revenue just because it has many
   customers. Average order value tells a different story: how much
   each individual purchase tends to be worth there.
   New concept: AVG(), and the idea that SUM and AVG answer genuinely
   different business questions even on the same data.
   --------------------------------------------------------------------- */
SELECT
    BillingCountry,
    ROUND(AVG(Total), 2) AS avg_invoice_value
FROM Invoice
GROUP BY BillingCountry
ORDER BY avg_invoice_value DESC
LIMIT 5;


/* ---------------------------------------------------------------------
   Q7. Which artists have the most tracks in our catalog?
   ---------------------------------------------------------------------
   This is a catalog question, not a sales question, so it never
   touches Invoice or InvoiceLine at all.
   New concept: COUNT() counts ROWS, not a numeric column, so
   COUNT(t.TrackId) here just means "how many track rows matched."
   --------------------------------------------------------------------- */
SELECT
    ar.Name AS artist,
    COUNT(t.TrackId) AS track_count
FROM Artist ar
JOIN Album al ON ar.ArtistId = al.ArtistId
JOIN Track t ON al.AlbumId = t.AlbumId
GROUP BY ar.ArtistId
ORDER BY track_count DESC
LIMIT 5;


/* ---------------------------------------------------------------------
   Q8. Which customers haven't purchased since mid-2024, and might be
       worth a re-engagement email?
   ---------------------------------------------------------------------
   This is a filtering question on top of an aggregate: we need each
   customer's MOST RECENT purchase date, then only keep the ones
   where that date is old.
   New concept: HAVING. WHERE filters rows before grouping; HAVING
   filters groups after aggregating. You can't write
   "WHERE MAX(InvoiceDate) < ..." -- that's exactly what HAVING is for.
   --------------------------------------------------------------------- */
SELECT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS customer_name,
    MAX(i.InvoiceDate) AS last_purchase
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
HAVING last_purchase < '2025-01-01'
ORDER BY last_purchase ASC
LIMIT 10;


/* ---------------------------------------------------------------------
   Q9. What percentage of total revenue does each genre represent?
   ---------------------------------------------------------------------
   To get a percentage, each row needs to know both its own revenue
   AND the grand total revenue across every row, at the same time.
   New concept: a subquery in the SELECT list -- a full query nested
   inside another one, here used to calculate one fixed number
   (total revenue) that every row can divide into.
   --------------------------------------------------------------------- */
SELECT
    g.Name AS genre,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS genre_revenue,
    ROUND(
        100.0 * SUM(il.UnitPrice * il.Quantity)
        / (SELECT SUM(UnitPrice * Quantity) FROM InvoiceLine),
        2
    ) AS pct_of_total
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY genre_revenue DESC
LIMIT 5;


/* ---------------------------------------------------------------------
   Q10. How much of our revenue comes from repeat customers versus
        one-time buyers?
   ---------------------------------------------------------------------
   This is a two-stage question: first figure out, per customer, how
   many invoices they have and how much they spent; then group THAT
   result into "repeat" vs "one-time" and total it up.
   New concept: a subquery in the FROM clause (sometimes called a
   derived table) -- you can treat the result of one query as if it
   were a table for a second query to run on. Also CASE WHEN, SQL's
   if/else, used here to label each customer.
   --------------------------------------------------------------------- */
SELECT
    CASE WHEN invoice_count > 1 THEN 'Repeat Customer' ELSE 'One-Time Customer' END AS customer_type,
    COUNT(*) AS num_customers,
    ROUND(SUM(total_spent), 2) AS revenue
FROM (
    SELECT
        CustomerId,
        COUNT(*) AS invoice_count,
        SUM(Total) AS total_spent
    FROM Invoice
    GROUP BY CustomerId
)
GROUP BY customer_type;

/* Note on Q10's result: in this particular dataset, every customer
   turns out to have more than one invoice, so "One-Time Customer"
   returns zero rows. That's a real, useful finding, not a bug: it
   tells you this business currently has no one-off buyers, which
   would change how you'd interpret a retention campaign. Try
   changing "invoice_count > 1" to "invoice_count > 5" to see how
   the split changes as you raise the bar for what counts as loyal. */
