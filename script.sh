#!/bin/bash -ex

function finish {
  cat first
  cat second
  docker logs jaeger || echo 'check http://10.71.47.216:16686/search'
}
trap finish EXIT

echo "RAILS_ENV=$RAILS_ENV"
cd service-first
bundle exec rails s >> ../first 2>&1 &
cd ../service-second
bundle exec rails s -p 3001 >> ../second 2>&1 &
cd ..
echo 'wait for puma to start...'
sleep 6

curl -f -X GET http://127.0.0.1:3000/second_service
sleep 6
curl -f -X GET http://127.0.0.1:16686/api/services | json_pp
curl -f -X GET http://127.0.0.1:16686/api/traces?service=ServiceFirst | json_pp
grep -v -i error first || grep -v -i error second


