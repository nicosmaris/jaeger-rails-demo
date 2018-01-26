class ApplicationController < ActionController::Base
  include OpentracingRails::Instrumenters::ActiveRecord

  protect_from_forgery with: :exception
end
