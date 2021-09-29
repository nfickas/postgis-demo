#!/bin/bash
name=$(kubectl get pod -n gisdemo -o custom-columns=":metadata.name" -l postgres-operator.crunchydata.com/cluster=hippo,postgres-operator.crunchydata.com/role=master)
name_2=${name%-*}
kubectl get secrets -n gisdemo $name_2-certs -o go-template='{{index .data "patroni.ca-roots" | base64decode}}'
kubectl get secrets -n gisdemo $name_2-certs -o go-template='{{index .data "dns.crt" | base64decode}}'
kubectl get secrets -n gisdemo $name_2-certs -o go-template='{{index .data "dns.key" | base64decode}}'
echo "Grafana Password: "
kubectl get secrets -n gisdemo hippo-pguser-grafana -o go-template='{{index .data "password" | base64decode}}'