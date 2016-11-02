create KEYSPACE test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
USE test;
CREATE TABLE stream_test (
    catalog_number text
    ,name text PRIMARY KEY
    ,basin text
    ,storm_timestamp timestamp
    ,lat_y float
    ,lon_x float
    ,max_wind_kts float
    ,min_cp_mb float
    ,sequence int
    ,fspeed_kts float
    ,is_landfall_point int
    ,rmax_nmi int
    ,gwaf float
    ,insert_timestamp timestamp);