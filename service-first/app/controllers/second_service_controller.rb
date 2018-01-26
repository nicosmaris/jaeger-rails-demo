class SecondServiceController < ApplicationController
  def index
    conn = Faraday.new(url: 'http://localhost:3001/') do |faraday|
      faraday.use Faraday::Tracer, span: current_span

      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    Article.last

    render plain: conn.get('/').body
  end
end
