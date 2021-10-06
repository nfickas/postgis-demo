GRANT SELECT ON county_boundary TO tileserv;
GRANT SELECT ON fire_hazard_areas TO featureserv;
GRANT SELECT ON fire_district_sphere_of_influence TO featureserv;
CREATE SCHEMA IF NOT EXISTS postgisftw;
GRANT SELECT ON fires to featureserv;
GRANT INSERT ON fires to featureserv;
GRANT SELECT ON fires_gid_seq to featureserv;
GRANT USAGE ON fires_gid_seq to featureserv;
GRANT USAGE ON SCHEMA postgisftw TO featureserv;