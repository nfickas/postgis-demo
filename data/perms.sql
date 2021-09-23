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


CREATE VIEW fires_for_departments AS
    SELECT
        soi.fire_soi AS fire_soi,
        soi.name AS department_name,
        fires.gid AS fire_id
    FROM fire_district_sphere_of_influence AS soi
    JOIN fires
    ON ST_Contains(soi.geom, fires.geom);

CREATE OR REPLACE FUNCTION postgisftw.detect_schools(distance integer)
RETURNS TABLE(gid integer, name varchar, grade_level varchar, dist float, geom geometry)
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON(f.gid) f.gid, f.name, f.grade_leve AS grade_level, (ST_Distance(f.geom::geography, s.geom::geography)) AS dist, f.geom 
    FROM facilities AS f, fires AS s 
    WHERE type_expl='School' AND ST_DWithin(f.geom::geography, s.geom::geography, distance);
END;
$$
LANGUAGE 'plpgsql' STABLE;

ALTER TABLE county_boundary
ADD COLUMN time timestamp;

UPDATE county_boundary
SET time = current_timestamp;

GRANT SELECT ON county_boundary to grafana;
GRANT SELECT ON facilities to grafana;
GRANT SELECT ON fires to grafana;

ALTER TABLE facilities
ADD COLUMN time timestamp;

UPDATE facilities
SET time = current_timestamp;