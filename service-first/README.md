# Rails opentracing

# installation

## Initializer

Since this gem is not binded to any opentracing implementation, user can choose which one wants to use.

Add an initializer for setting up the implementation:

```ruby
# config/initializers/opentracing.rb

require 'opentracing'
require 'jaeger/client'

OpenTracing.global_tracer = Jaeger::Client.build(service_name: Rails.application.class.parent_name)
```
