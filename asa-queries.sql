-- Hello World of streaming
SELECT *
INTO alldata
FROM donutshop

--  Cosmos DB queries against this data:
SELECT top 10 * from c

SELECT sum(c.donutCount) as donuts FROM c
where c.partitionId = "2"
and
 c.donutType = "blueberry"

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
-- Needs partition ID, for Cosmos DB (not the best choice of partition id, but lets us query and see all aggregates together)
SELECT
    COUNT(*) as 'sampleCount',
    SUM(donutCount) as 'donutCount',
    SUM(qcIssueCount) as 'qcIssueCount',
    System.TimeStamp AS 'windowEnd',
    partitionId
INTO
    aggregatedcounts
FROM
    donutshop TIMESTAMP BY eventTime
GROUP BY partitionId, TumblingWindow(second,15)

-- donut counts per minute, by type
SELECT donutType, SUM(donutCount),
System.TimeStamp AS 'windowEnd',
partitionId
INTO donutcounts 
FROM donutshop TIMESTAMP by eventTime
GROUP BY partitionId, TumblingWindow(minute,1),donutType, windowEnd

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
-- In this example, flag stores having more than a few issues in a 30 second sliding window
SELECT
    storeId,
    System.TimeStamp AS 'windowEnd',
    SUM(qcIssueCount) as 'qcIssueCount',
    partitionId
INTO
    qcissues
FROM
    donutshop TIMESTAMP BY eventTime
GROUP BY partitionId,storeId,SlidingWindow(second,30)
HAVING qcIssueCount > 20

-- track down stores selling donuts that aren't sold anymore
SELECT
    [donutshop].storeId,
    [donutshop].donutType,
    SUM([donutshop].donutCount) as 'donutCount',
    System.TimeStamp AS 'windowEnd',
    [donutshop].partitionId as 'partitionId'
INTO
    [expiredpromotions]
FROM
    [donutshop] TIMESTAMP BY eventTime
JOIN [donuttypes]
ON [donutshop].donutType = [donutTypes].DonutName
WHERE donutTypes.IsCurrent = 0
GROUP BY [donutshop].partitionId,[donutshop].storeId,[donutshop].donutType,TumblingWindow(minute,1)

-- multiple queries together
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

SELECT
    COUNT(*) as 'sampleCount',
    SUM(donutCount) as 'donutCount',
    SUM(qcIssueCount) as 'qcIssueCount',
    System.TimeStamp AS 'windowEnd',
    partitionId
INTO
    aggregatedcounts
FROM
    donutshop TIMESTAMP BY eventTime
GROUP BY partitionId, TumblingWindow(second,15)

SELECT donutType, SUM(donutCount),
System.TimeStamp AS 'windowEnd',
partitionId
INTO donutcounts 
FROM donutshop TIMESTAMP by eventTime
GROUP BY partitionId, TumblingWindow(minute,1),donutType, windowEnd

SELECT
    storeId,
    System.TimeStamp AS 'windowEnd',
    SUM(qcIssueCount) as 'qcIssueCount',
    partitionId
INTO
    qcissues
FROM
    donutshop TIMESTAMP BY eventTime
GROUP BY partitionId,storeId,SlidingWindow(second,30)
HAVING qcIssueCount > 20

SELECT
    [donutshop].storeId,
    [donutshop].donutType,
    SUM([donutshop].donutCount) as 'donutCount',
    System.TimeStamp AS 'windowEnd',
    [donutshop].partitionId as 'partitionId'
INTO
    [expiredpromotions]
FROM
    [donutshop] TIMESTAMP BY eventTime
JOIN [donuttypes]
ON [donutshop].donutType = [donutTypes].DonutName
WHERE donutTypes.IsCurrent = 0
GROUP BY [donutshop].partitionId,[donutshop].storeId,[donutshop].donutType,TumblingWindow(minute,1)

-- set up reference data to make sure only "current" donuts are being produced
create table DonutTypes(Id Bigint,DonutName Nvarchar(max),IsCurrent BigInt);
insert into dbo.DonutTypes (Id, DonutName, IsCurrent) values (1, 'chocolate',1)
insert into dbo.DonutTypes (Id, DonutName, IsCurrent) values (2, 'plain',1)
insert into dbo.DonutTypes (Id, DonutName, IsCurrent) values (3, 'blueberry',1)
insert into dbo.DonutTypes (Id, DonutName, IsCurrent) values (4, 'boston creme',1)
insert into dbo.DonutTypes (Id, DonutName, IsCurrent) values (5, 'coconut',1)
insert into dbo.DonutTypes (Id, DonutName, IsCurrent) values (6, 'valentines heart',0)
