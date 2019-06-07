-- Hello World of streaming
SELECT *
INTO alldata
FROM donutshop

-- Grab specific fields
SELECT
    id,
    eventTime,
    donutType,
    qcIssueCount,
    partitionId
INTO
    filtereddata
FROM
    donutshop TIMESTAMP BY eventTime

-- simple aggregation: number of samples, and all sums, in a 15 second period
SELECT
    COUNT(*) as 'sampleCount',
    SUM(donutCount) as 'donutCount',
    SUM(qcIssueCount) as 'qcIssueCount',
    System.TimeStamp AS 'windowEnd'
INTO
    aggregatedcounts
FROM
    donutshop TIMESTAMP BY eventTime
GROUP BY TumblingWindow(second,15)

-- donut counts per minute, by type
SELECT donutType, SUM(donutCount),
System.TimeStamp AS 'windowEnd'
INTO aggregatedcounts 
FROM donutshop TIMESTAMP by eventTime
GROUP BY TumblingWindow(minute,1),donutType, windowEnd

-- sum donut counts and measurement counts, by store
SELECT
    storeId,
    partitionId,
    System.TimeStamp AS 'windowEnd',
    SUM(donutCount) as 'donutCount',
    COUNT(*) as 'measurementCount'
INTO
    [summary]
FROM
    [donutshop]
GROUP BY TumblingWindow(minute,1),storeId

-- Look for quality control issues
-- In this example, flag stores having more than 1 issue in a 30 second window
SELECT
    storeId,
    System.TimeStamp AS 'windowEnd',
    SUM(qcIssueCount) as 'qcIssueCount'
INTO
    [summary]
FROM
    [donutshop] TIMESTAMP BY eventTime
GROUP BY storeId,SlidingWindow(second,30)
HAVING qcIssueCount > 20

/* maybe have multiple sensors in a conveyor belt?
 - start
 - fry
 - fill
 - glaze 
 - sprinkle
 - heat
 - done?
*/