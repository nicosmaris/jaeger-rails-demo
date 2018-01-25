Rails.application.routes.draw do
  get '/second_service', to: 'second_service#index'
  get '/ping_pong', to: 'ping_pong#index'
end
