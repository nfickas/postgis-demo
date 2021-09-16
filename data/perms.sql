GRANT SELECT ON fire_hazard_areas TO tileserv;
GRANT SELECT ON fire_district_sphere_of_influence TO tileserv;
GRANT SELECT ON county_boundary TO tileserv;
GRANT SELECT ON fire_hazard_areas TO featureserv;
CREATE SCHEMA IF NOT EXISTS postgisftw;
GRANT USAGE ON SCHEMA postgisftw TO featureserv;

CREATE OR REPLACE FUNCTION postgisftw.generate_fires(fire_hazard_level text)
RETURNS TABLE(geo geometry)
AS $$
BEGIN
	RETURN QUERY
		SELECT ST_GeneratePoints(geom, 1)
        FROM (
            SELECT t.geom
    FROM fire_hazard_areas t
    WHERE t.firehazard=fire_hazard_level) AS geom;
END;
$$
LANGUAGE 'plpgsql' STABLE PARALLEL SAFE;

COMMENT ON FUNCTION postgisftw.generate_fires IS 'Creates a point fire';