[![TravisCI Build Status](https://travis-ci.org/nicosmaris/jaeger-rails-demo.svg?branch=master)](https://travis-ci.org/nicosmaris/jaeger-rails-demo)

# jaeger-rails-demo

Demo of Opentracing and Jaeger usage on top of a Ruby on Rails app using opentracing-rails gem based on the following files:
```
service-first/app/controllers/second_service_controller.rb
service-first/config/initializers/opentracing.rb
```

## Development

```bash
docker run \
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
# continue in another terminal
cd service-first/
rails s
# continue in another terminal
cd ../service-second/
rails s -p 3001
```

## Start tracing actions

Open your browser in:
`http://localhost:3000/second_service`

Now, you should be able to see the traces into Jaeger UI `http://localhost:16686`

## Deployment

Check the file .travis.yml

# Documentation

If you go to the doc folder and `python -m SimpleHTTPServer`, you will see at localhost:8000 the added classes under config/initializers/opentracing.rb and their usage at service-first/app/controllers/second_service_controller.rb

## Blacklist

We do not plan to support faraday
