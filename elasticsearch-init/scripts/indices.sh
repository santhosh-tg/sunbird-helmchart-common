#!/bin/bash
set -x
until curl -s http://elasticsearch:9200; do
  echo 'Waiting
    for Elasticsearch to be ready...'
  sleep 10
done
echo 'Elasticsearch is ready!'

ls -lrth /opt

cd /opt/indices 

echo "Creating indices"

indices_files=$(ls -l | awk 'NR>1{print $9}' | awk -F"." '{print $1}' | tr "\n" " ")
for file in ${indices_files[@]}
do
        curl  -X PUT http://elasticsearch:9200/${file} -H 'Content-Type: application/json' -d @${file}.json
done

echo "Creating mappings"

cd /opt/mappings

# Exclude compositesearch from the list as the mapping type is different
mapping_files=$(ls -l -I compositesearch-mapping.json | awk 'NR>1{print $9}' | awk -F"." '{print $1}' | tr "\n" " " | sed 's/-mapping//g')

# Create mapping for compositesearch with type cs
curl  -X PUT http://localhost:9200/compositesearch/_mapping/cs -H 'Content-Type: application/json' -d @compositesearch-mapping.json

for file in ${mapping_files[@]}
do
        curl  -X PUT http://elasticsearch:9200/${file}/_mapping/_doc -H 'Content-Type: application/json' -d @${file}-mapping.json
done
