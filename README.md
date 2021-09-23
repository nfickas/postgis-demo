# postgis-demo

export PG_CLUSTER_SUPERUSER_SECRET_NAME=hippo-pguser-postgres
export PGSUPERPASS=$(kubectl get secrets -n nate-test "${PG_CLUSTER_SUPERUSER_SECRET_NAME}" -o go-template='{{.data.password | base64decode}}')
export PGSUPERUSER=$(kubectl get secrets -n nate-test "${PG_CLUSTER_SUPERUSER_SECRET_NAME}" -o go-template='{{.data.user | base64decode}}')
PGPASSWORD=$PGSUPERPASS psql -h localhost -U $PGSUPERUSER -d postgres < ./data/postgis.sql
shp2pgsql -D -s 4326 ./data/County_Boundary/County_Boundary.shp | PGPASSWORD=$PGSUPERPASS psql -d postgres -h localhost -U $PGSUPERUSER
shp2pgsql -D -s 4326 ./data/Fire_Hazard_Areas/Fire_Hazard_Areas.shp | PGPASSWORD=$PGSUPERPASS psql -d postgres -h localhost -U $PGSUPERUSER
PGPASSWORD=$PGSUPERPASS psql -h localhost -U $PGSUPERUSER -d postgres < ./data/perms.sql

shp2pgsql -D -s 4326 ./data/Fire_District_Sphere_of_Influence/Fire_District_Sphere_of_Influence.shp | PGPASSWORD=$PGSUPERPASS psql -d postgres -h localhost -U $PGSUPERUSER
shp2pgsql -D -s 4326 ./data/Facilities/Facilities.shp | PGPASSWORD=$PGSUPERPASS psql -d postgres -h localhost -U $PGSUPERUSER

kubectl apply -k kustomize/pg_tileserv
kubectl apply -k kustomize/pg_featureserv