class HomeController < ApplicationController
  def index
    Article.last
    conn = Faraday.new(url: 'http://localhost:3000/') do |faraday|
      faraday.use Faraday::Tracer, span: current_span

      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    render plain: conn.get('/ping_pong').body
  end
end
