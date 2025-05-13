/*
This query identifies both the top five and bottom five neighborhoods based on the accessibility metric. 
The top five neighborhoods are ranked in descending order, while the bottom five are ranked in ascending order.
*/

SELECT * FROM assignment2.phlmetrics
ORDER BY
    accessibility_metric DESC
LIMIT 5;