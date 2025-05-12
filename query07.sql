/*
What are the bottom five neighborhoods according to your accessibility metric? Ascending order
*/

SELECT * FROM assignment2.phlmetrics
ORDER BY
    accessibility_metric ASC
LIMIT 5;