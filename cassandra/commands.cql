create KEYSPACE test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
USE test;
CREATE TABLE stream_test (
    catalog_number text
    ,name text
    ,basin text
    ,storm_timestamp text
    ,lat_y text
    ,lon_x text
    ,max_wind_kts text
    ,min_cp_mb text
    ,sequence text
    ,fspeed_kts text
    ,is_landfall_point text
    ,rmax_nmi text
    ,gwaf text
    ,insert_timestamp text PRIMARY KEY);