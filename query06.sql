/*
This query identifies both the top five and bottom five neighborhoods based on the accessibility metric. 
The top five neighborhoods are ranked in descending order, while the bottom five are ranked in ascending order.
*/

WITH top_five AS (
    SELECT *
    FROM assignment2.phlmetrics
    ORDER BY accessibility_metric DESC
    LIMIT 5
),
bottom_five AS (
    SELECT *
    FROM assignment2.phlmetrics
    ORDER BY accessibility_metric ASC
    LIMIT 5
)
SELECT * 
FROM top_five
UNION ALL
SELECT * 
FROM bottom_five;