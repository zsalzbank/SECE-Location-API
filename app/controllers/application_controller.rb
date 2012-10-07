class ApplicationController < ActionController::Base
  protect_from_forgery
  after_filter :set_headers

  def set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end
end
