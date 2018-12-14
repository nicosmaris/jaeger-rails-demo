#require 'faraday'
#require 'faraday/tracer'

class HomeController < ApplicationController
  def index
    # doing a DB request just to track it
    #Article.last
    # doing an external API call just to track it
    #conn = Faraday.new(url: 'http://localhost:3000/') do |faraday|
    #  faraday.use Faraday::Tracer, span: request.env['rack.span']

    #  faraday.request :url_encoded
    #  faraday.adapter Faraday.default_adapter
    #end

    render plain: 'OK from second service'
  end
end
