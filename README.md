# Introduction to Stream Processing

This repo contains the PowerPoint, and sample queries, demonstrated at the following events:

 - RevolutionConf 2019 (June 7, Virginia Beach, VA)
 - DataChangers Meetup (June 18, Amsterdam, NL)
 - CMAP User Group (July 2, Columbia, MD)

## The demo

All demo queries are in [asa-queries.sql](asa-queries.sql), and are written specifically for Azure Stream Analytics. You'll need to set up a few things first:

 - Build and configure the `donutsimulator` app (which pretends to be an IoT device). You'll need to register your new device (the simulator) with an IoT Hub.
 - Set up an new Stream Analytics job, and configure an input (IoT Hub) for donut data, and several outputs (Cosmos DB collections, with partition id of `partitionId`).
 - To run the query that checks for shops selling out-dated promotions, you'll need to set up a reference database (a simple SQL Database) and load the data at the end of `asa-queries.sql`

# Stream Processing 101 (in Stream Analytics)

## The basics

Stream processing is a way of querying, and gaining insights, from data as it arrives. When thinking about "live" data, there are so many different sources and applications for stream processing. for example:
 - Vehicle telemetry (speed, location, direction...)
 - Factory assembly lines
 - Weather stations (temperature, humidity, wind, precipitation...)
 - Website clickstreams
 - Sports data
 - Aircraft positioning

## Temporal capabilities

Stream processing's "magic" is in its ability to perform real-time aggregations within *windows* of time. That is, within a given, recurring time window (say, 5 minutes, or 1 hour), perform specific aggregations on data arriving within that time window, and emit results for each of those time windows. A few examples:

 - Average vehicle speed, per minude, within a given location
 - Number of widgets assembled per hour, per assembly line
 - Average temperature and humidity per hour, per city/town
 - Min/max/avg number of page views, per second, for a website

 While time-based queries can be done with traditional OLTP databases (SQL Server, MongoDB, Neo4j, Cassandra, etc), these queries take place *after data has arrived and has been stored within the database*. And, depending on the time-window size, it's possible that, in a traditional database, an time-based aggregation query would need to be run very often. Imagine the load on a database engine if, for example, you wanted Player Stats (high score list, etc) for an online game to be updated once per second.

 ## Window types

 There are three fundamental time-window types: *Tumbling*, *Hopping*, and *Sliding*.

### Tumbling windows

*Tumbling* windows are consecutive time windows, with no overlap.


### Hopping windows

*Hopping* windows are similar to tumbling windows, but the windows can overlap (they don't have to line up end-to-end). Entirely possible that the same data point is counted in multiple windows.

### Sliding windows

*Sliding* windows move continuously.