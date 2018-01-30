class PingPongController < ApplicationController
  def index
    Article.last
    render plain: 'Ping pong'
  end
end
