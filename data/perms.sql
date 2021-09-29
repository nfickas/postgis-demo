GRANT SELECT ON fire_hazard_areas TO tileserv;
GRANT SELECT ON county_boundary TO tileserv;
GRANT SELECT ON fire_hazard_areas TO featureserv;
GRANT SELECT ON fire_district_sphere_of_influence TO featureserv;
CREATE SCHEMA IF NOT EXISTS postgisftw;
CREATE TABLE fires (gid serial PRIMARY KEY, geom geometry(POINT, 4326));
GRANT SELECT ON fires to featureserv;
GRANT INSERT ON fires to featureserv;
GRANT SELECT ON fires_gid_seq to featureserv;
GRANT USAGE ON fires_gid_seq to featureserv;
GRANT USAGE ON SCHEMA postgisftw TO featureserv;
GRANT USAGE ON SCHEMA postgisftw TO grafana;
GRANT SELECT ON county_boundary to grafana;
GRANT SELECT ON facilities to grafana;
GRANT SELECT ON fires to grafana;

ALTER TABLE county_boundary
ADD COLUMN time timestamp;

UPDATE county_boundary
SET time = current_timestamp;

ALTER TABLE facilities
ADD COLUMN time timestamp;

UPDATE facilities
SET time = current_timestamp;