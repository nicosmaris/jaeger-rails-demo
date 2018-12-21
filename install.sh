#!/bin/bash -x

docker run -d \
    -e COLLECTOR_ZIPKIN_HTTP_PORT=9411 \
    -p5775:5775/udp \
    -p6831:6831/udp \
    -p6832:6832/udp \
    -p5778:5778 \
    -p16686:16686 \
    -p14268:14268 \
    -p9411:9411 \
    --name jaeger \
    jaegertracing/all-in-one:latest --log-level debug
 
echo "RAILS_ENV=$RAILS_ENV"
cd service-first
bundle install
bundle exec rails db:migrate
cd ../service-second
bundle install
bundle exec rails db:migrate
cd ..
echo 'wait for gems and migrations to finish...'
sleep 6


