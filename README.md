# postgis-demo

export PG_CLUSTER_SUPERUSER_SECRET_NAME=hippo-pguser-postgres                                           
export PGSUPERPASS=$(kubectl get secrets -n nate-test "${PG_CLUSTER_SUPERUSER_SECRET_NAME}" -o go-template='{{.data.password | base64decode}}')
export PGSUPERUSER=$(kubectl get secrets -n nate-test "${PG_CLUSTER_SUPERUSER_SECRET_NAME}" -o go-template='{{.data.user | base64decode}}')
PGPASSWORD=$PGSUPERPASS psql -h localhost -U $PGSUPERUSER -d uscounties < ./data/postgis.sql
PGPASSWORD=$PGSUPERPASS pg_restore -h localhost -U $PGSUPERUSER -d uscounties ./data/census.sql
PGPASSWORD=$PGSUPERPASS psql -h localhost -U $PGSUPERUSER -d uscounties < ./data/perms.sql