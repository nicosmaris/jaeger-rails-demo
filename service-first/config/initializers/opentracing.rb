require 'jaeger/client'
require 'opentracing'
require 'logger'

jaeger_host='10.71.47.216'
# for travis in which RAILS_ENV is test
if Rails.env.test?
  jaeger_host = '127.0.0.1'
end

OpenTracing.global_tracer = Jaeger::Client.build(
  host: jaeger_host,
  port: 5775,
  service_name: 'CompleteService',
  reporter: Jaeger::Reporters::LoggingReporter.new
)
#################################################

## 
# Format: OpenTracing::FORMAT_TEXT_MAP
# input: env
# output: env['scope_span_context']

class RackExtractTracingMiddleware
  def initialize(app)
    @app = app
  end
  def call(env)
    result = nil
    tracer = OpenTracing.global_tracer
    scope_span_context = tracer.extract(OpenTracing::FORMAT_TEXT_MAP, env)
    tracer.start_active_span(
      env["REQUEST_METHOD"] + ' ' + env["rack.url_scheme"] + '://' + env["HTTP_HOST"] + env["REQUEST_URI"],
      child_of: scope_span_context,
      tags: {
        'component' => Rails.application.class.parent_name,
        'span.kind' => 'RackExtractTracingMiddleware',
        'http.method' => env["REQUEST_METHOD"],
        'http.url' => env["rack.url_scheme"] + '://' + env["HTTP_HOST"] + env["REQUEST_URI"]
      }
    ) do |scope|
      # TODO: log to sentry "trace id #{scope.span.context.to_trace_id} generated rails request id #{env['action_dispatch.request_id']}"
      result = @app.call(env).tap do |status_code, _headers, _body|
        scope.span.set_tag('http.status_code', status_code) 
      end
    end
    result
  end
end
Rails.configuration.middleware.use(RackExtractTracingMiddleware)
Rails.configuration.middleware.insert_after(ActionDispatch::RequestId, RackExtractTracingMiddleware)
#################################################

##
# Format: OpenTracing::FORMAT_TEXT_MAP
# input: OpenTracing.active_span
# output: -


class DBTracingMiddleware
  def call(name, started, finished, unique_id, payload)
    statement = payload.fetch(:sql)
    connection_id = payload.fetch(:connection_id, 'unknown')
    cached = payload.fetch(:cached, false)
    connection_config = ActiveRecord::Base.connection_config

    tracer = OpenTracing.global_tracer
    span = tracer.start_span(
      statement,
      child_of: OpenTracing.active_span,
      start_time: Time.now,
      tags: {
        'component' => Rails.application.class.parent_name,
        'span.kind' => 'DBTracingMiddleware',
        'db.user' => connection_config.fetch(:username, 'unknown'),
        'db.instance' => connection_config.fetch(:database),
        'db.vendor' => connection_config.fetch(:adapter),
        'db.connection_id' => connection_id,
        'db.cached' => cached,
        'db.statement' => statement
      }
    )
    #do |scope|
    #end
    span.finish
  end
end

ActiveSupport::Notifications.subscribe('sql.active_record', DBTracingMiddleware.new)

