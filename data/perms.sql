GRANT SELECT ON fire_hazard_areas TO tileserv;
GRANT SELECT ON county_boundary TO tileserv;
GRANT SELECT ON fire_hazard_areas TO featureserv;
CREATE SCHEMA IF NOT EXISTS postgisftw;
CREATE TABLE fires (gid serial PRIMARY KEY, geom geometry(MultiPoint, 4326));
GRANT SELECT ON fires to featureserv;
GRANT INSERT ON fires to featureserv;
GRANT SELECT ON fires_gid_seq to featureserv;
GRANT USAGE ON fires_gid_seq to featureserv;
GRANT USAGE ON SCHEMA postgisftw TO featureserv;

CREATE OR REPLACE FUNCTION postgisftw.generate_fires(fire_hazard_level text)
RETURNS TABLE(geo geometry) 
AS $$
BEGIN
    INSERT INTO fires(geom)
    VALUES(
        (SELECT ST_GeneratePoints(geom, 1)
        FROM (
            SELECT t.geom
            FROM fire_hazard_areas t
            WHERE t.firehazard=fire_hazard_level ORDER BY random() LIMIT 1) AS geom)
    );
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

COMMENT ON FUNCTION postgisftw.generate_fires IS 'Creates a point fire';