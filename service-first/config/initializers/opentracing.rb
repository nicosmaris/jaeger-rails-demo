require 'jaeger/client'
require 'opentracing'

require 'logger'

jaeger_host='10.71.47.216'
# for travis in which RAILS_ENV is test
if Rails.env.test?
  jaeger_host = '127.0.0.1'
end

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

OpenTracing.global_tracer = Jaeger::Client.build(
  host: jaeger_host,
  port: 5775,
  service_name: Rails.application.class.parent_name,
  logger: logger
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
  #def self.inject
  #  # A static method
  #end
  def call(env)
    result = nil
    tracer = OpenTracing.global_tracer
    scope_span_context = tracer.extract(OpenTracing::FORMAT_TEXT_MAP, env)
    tracer.start_active_span(
      env["REQUEST_METHOD"] + ' ' + env["rack.url_scheme"] + '://' + env["HTTP_HOST"] + env["REQUEST_URI"],
      child_of: scope_span_context,
      tags: {
        'component' => 'rails',
        'span.kind' => 'server',
        'http.method' => env["REQUEST_METHOD"],
        'http.url' => env["rack.url_scheme"] + '://' + env["HTTP_HOST"] + env["REQUEST_URI"]
      }
    ) do |scope|
      # TODO: log to sentry "trace id #{scope.span.context.to_trace_id} generated rails request id #{env['action_dispatch.request_id']}"
      tracer.inject(scope.span.context, OpenTracing::FORMAT_TEXT_MAP, env)
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
# input: env
# output: env[:request_headers]

class FaradayInjectTracingMiddleware
  def initialize(app)
    @app = app
  end
  #def self.inject
  #  # A static method
  #end
  def call(env)
    result = nil
    tracer = OpenTracing.global_tracer
    scope_span_context = tracer.extract(OpenTracing::FORMAT_TEXT_MAP, env)
    tracer.start_active_span(
      env[:method].to_s.upcase + ' ' + env[:url].to_s,
      child_of: scope_span_context,
      tags: {
        'component' => 'rails',
        'span.kind' => 'server',
        'http.method' => env[:method].to_s.upcase,
        'http.url' => env[:url].to_s
      }
    ) do |scope|
      # TODO: log to sentry "trace id #{scope.span.context.to_trace_id} generated faraday request #{env[:method]} #{env[:url].to_s}"
      tracer.inject(scope.span.context, OpenTracing::FORMAT_TEXT_MAP, env[:request_headers])
      result = @app.call(env).on_complete do |response_env|
        scope.span.set_tag('http.status_code', response_env.status.to_s) 
      end
    end
    result
  end
end

