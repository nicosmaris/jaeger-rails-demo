require 'faraday'

class SecondServiceController < ApplicationController
  def index
    # doing an external API call just to track it
    conn = Faraday.new(url: 'http://127.0.0.1:3001/') do |faraday|
      faraday.use FaradayInjectTracingMiddleware
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    # doing a DB request just to track it
    Article.last

    render plain: conn.get('/').body
  end
end
