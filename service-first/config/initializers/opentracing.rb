require 'jaeger/client'

OpenTracing.global_tracer = Jaeger::Client.build(
  service_name: Rails.application.class.parent_name)
