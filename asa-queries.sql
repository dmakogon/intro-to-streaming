-- Hello World of streaming
SELECT *
INTO stats
FROM donutshop

-- Grab specific fields
SELECT
    id,
    eventTime,
    donutType,
    qcPassed,
    'sample' as statType
INTO
    stats
FROM
    donutshop TIMESTAMP BY eventTime

-- simple aggregation: number of samples in a 15 second period
SELECT
    COUNT(*) as DonutCount,
    'summaryCount' as statType
INTO
    stats
FROM
    donutshop TIMESTAMP BY eventTime
GROUP BY TumblingWindow(second,15)

-- donut counts per minute, by type
SELECT donutType, SUM(donutCount)
INTO stats
FROM donutshop TIMESTAMP by eventTime
GROUP BY TumblingWindow(minute,1),donutType

-- sum donut counts and measurement counts, by store
SELECT
    storeId,
    '1' as 'partitionId',
    System.TimeStamp AS 'windowEnd',
    SUM(donutCount) as 'donutCount',
    COUNT(*) as 'measurementCount',
    'storeSummaryCount' as 'statType'
INTO
    [summary]
FROM
    [donutshop]
GROUP BY TumblingWindow(minute,1),storeId

/* maybe have multiple sensors in a conveyor belt?
 - start
 - fry
 - fill
 - glaze 
 - sprinkle
 - heat
 - done?
*/