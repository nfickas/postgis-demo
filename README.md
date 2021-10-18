# postgis-demo

export PG_CLUSTER_SUPERUSER_SECRET_NAME=hippo-pguser-postgres
export PGSUPERPASS=$(kubectl get secrets -n gisdemo "${PG_CLUSTER_SUPERUSER_SECRET_NAME}" -o go-template='{{.data.password | base64decode}}')
export PGSUPERUSER=$(kubectl get secrets -n gisdemo "${PG_CLUSTER_SUPERUSER_SECRET_NAME}" -o go-template='{{.data.user | base64decode}}')

PGPASSWORD=$PGSUPERPASS psql -h localhost -U $PGSUPERUSER -d postgres < ./data/postgis.sql

shp2pgsql -D -s 4326 ./data/County_Boundary/County_Boundary.shp | PGPASSWORD=$PGSUPERPASS psql -d postgres -h localhost -U $PGSUPERUSER
shp2pgsql -D -s 4326 ./data/Fire_Hazard_Areas/Fire_Hazard_Areas.shp | PGPASSWORD=$PGSUPERPASS psql -d postgres -h localhost -U $PGSUPERUSER
shp2pgsql -D -s 4326 ./data/Fire_District_Sphere_of_Influence/Fire_District_Sphere_of_Influence.shp | PGPASSWORD=$PGSUPERPASS psql -d postgres -h localhost -U $PGSUPERUSER
shp2pgsql -D -s 4326 ./data/Facilities/Facilities.shp | PGPASSWORD=$PGSUPERPASS psql -d postgres -h localhost -U $PGSUPERUSER

CREATE TABLE fires (gid serial PRIMARY KEY, geom geometry(POINT, 4326));

PGPASSWORD=$PGSUPERPASS psql -h localhost -U $PGSUPERUSER -d postgres < ./data/perms.sql

PGPASSWORD=$PGSUPERPASS psql -h localhost -U $PGSUPERUSER -d postgres

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


CREATE OR REPLACE FUNCTION postgisftw.schools_within_distance(School_Name text, distance integer)
RETURNS TABLE(name varchar)
AS $$
BEGIN
    RETURN QUERY
    SELECT f.name
    FROM facilities AS f
    WHERE ST_DWithin(f.geom::geography, (SELECT geom FROM facilities AS s WHERE s.name=School_Name LIMIT 1)::geography, distance) AND type_expl='School' AND f.name!=School_Name;
END;
$$
LANGUAGE 'plpgsql' STABLE;

CREATE OR REPLACE FUNCTION postgisftw.fires_within_distance_of_school(School_Name text, distance integer)
RETURNS TABLE(num bigint)
AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(*)
    FROM fires AS f
    WHERE ST_DWithin((SELECT geom FROM facilities WHERE name=School_Name)::geography, f.geom::geography, distance)
END;
$$
LANGUAGE 'plpgsql' STABLE;
