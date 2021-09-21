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

CREATE OR REPLACE FUNCTION postgisftw.generate_fires(fire_hazard_level text, num_fires integer default 1)
RETURNS TABLE(geo geometry) 
AS $$
BEGIN
    INSERT INTO fires(geom)
        (SELECT ST_GeometryN(ST_GeneratePoints(geom, 1), 1)
        FROM (
            SELECT t.geom
            FROM fire_hazard_areas t
            WHERE t.firehazard=fire_hazard_level ORDER BY random() LIMIT num_fires) AS geom);
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

COMMENT ON FUNCTION postgisftw.generate_fires IS 'Creates a point fire';

CREATE OR REPLACE FUNCTION postgisftw.count_fires()
RETURNS TABLE(num bigint)
AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(*)
    FROM fires;
END;
$$
LANGUAGE 'plpgsql' STABLE;


CREATE OR REPLACE FUNCTION postgisftw.count_fires(department_name text)
RETURNS TABLE(num integer)
AS $$
BEGIN
    RETURN QUERY
        SELECT
            COUNT(*)
        FROM fire_district_sphere_of_influence AS soi
        JOIN fires
        ON ST_Contains(soi.geom, fires.geom);
END;
$$
LANGUAGE 'plpgsql' STABLE;

CREATE VIEW fires_for_departments AS
    SELECT
        soi.fire_soi AS fire_soi,
        soi.name AS department_name,
        fires.gid AS fire_id
    FROM fire_district_sphere_of_influence AS soi
    JOIN fires
    ON ST_Contains(soi.geom, fires.geom);