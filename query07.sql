/*
What are the _bottom five_ neighborhoods according to your accessibility metric?
*/
SELECT * FROM phl.wheelchair_accessibility
ORDER BY wheelchair_accessibility ASC
LIMIT 5;