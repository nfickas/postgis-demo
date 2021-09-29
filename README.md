# postgis-demo

export PG_CLUSTER_SUPERUSER_SECRET_NAME=hippo-pguser-postgres
export PGSUPERPASS=$(kubectl get secrets -n nate-test "${PG_CLUSTER_SUPERUSER_SECRET_NAME}" -o go-template='{{.data.password | base64decode}}')
export PGSUPERUSER=$(kubectl get secrets -n nate-test "${PG_CLUSTER_SUPERUSER_SECRET_NAME}" -o go-template='{{.data.user | base64decode}}')

PGPASSWORD=$PGSUPERPASS psql -h localhost -U $PGSUPERUSER -d postgres < ./data/postgis.sql

shp2pgsql -D -s 4326 ./data/County_Boundary/County_Boundary.shp | PGPASSWORD=$PGSUPERPASS psql -d postgres -h localhost -U $PGSUPERUSER
shp2pgsql -D -s 4326 ./data/Fire_Hazard_Areas/Fire_Hazard_Areas.shp | PGPASSWORD=$PGSUPERPASS psql -d postgres -h localhost -U $PGSUPERUSER
shp2pgsql -D -s 4326 ./data/Fire_District_Sphere_of_Influence/Fire_District_Sphere_of_Influence.shp | PGPASSWORD=$PGSUPERPASS psql -d postgres -h localhost -U $PGSUPERUSER
shp2pgsql -D -s 4326 ./data/Facilities/Facilities.shp | PGPASSWORD=$PGSUPERPASS psql -d postgres -h localhost -U $PGSUPERUSER

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

Just testing
