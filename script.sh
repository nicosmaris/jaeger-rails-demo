#!/bin/bash -ex

echo "RAILS_ENV=$RAILS_ENV"
cd service-first
bundle install
bundle exec rails db:migrate
cd ../service-second
bundle install
bundle exec rails db:migrate
cd ..
echo 'wait for gems and migrations to finish...'
sleep 3

cd service-first
bundle exec rails s >> ../first 2>&1 &
cd ../service-second
bundle exec rails s -p 3001 >> ../second 2>&1 &
cd ..
echo 'wait for puma to start...'
sleep 3

curl -X GET http://localhost:3000/second_service
cat first
cat second
grep -v -i error first || grep -v -i error second
