#require 'faraday'
#require 'faraday/tracer'

class SecondServiceController < ApplicationController
  def index
    # doing an external API call just to track it
    #conn = Faraday.new(url: 'http://localhost:3001/') do |faraday|
    #  faraday.use Faraday::Tracer, span: request.env['rack.span']

    #  faraday.request :url_encoded
    #  faraday.adapter Faraday.default_adapter
    #end

    # doing a DB request just to track it
    Article.last

    render plain: 'OK from first service'
  end
end
