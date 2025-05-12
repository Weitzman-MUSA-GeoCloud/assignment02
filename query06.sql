/*
What are the top five neighborhoods according to your accessibility metric? Descending order
*/

SELECT * FROM assignment2.phlmetrics
ORDER BY
    accessibility_metric DESC
LIMIT 5;