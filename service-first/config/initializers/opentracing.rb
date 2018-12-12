require 'jaeger/client'
require 'opentracing'

OpenTracing.global_tracer = Jaeger::Client.build(
  host: '10.71.47.216',
  port: 5775,
  service_name: Rails.application.class.parent_name
)
#################################################
class TracingMiddleware
  REQUEST_URI = 'REQUEST_URI'.freeze
  REQUEST_METHOD = 'REQUEST_METHOD'.freeze
  def initialize(app # rubocop:disable Metrics/ParameterLists
                )
    @app = app
  end

  def call(env)
    result = nil
    OpenTracing.global_tracer.start_active_span("my_span") do |scope|
      #OpenTracing.inject(span.context, OpenTracing::FORMAT_RACK, env)
      result = @app.call(env).tap do |status_code, _headers, _body|
      end
    end
    result
  end

end
#################################################
Rails.configuration.middleware.use(TracingMiddleware)
Rails.configuration.middleware.insert_after(ActionDispatch::RequestId, TracingMiddleware)


