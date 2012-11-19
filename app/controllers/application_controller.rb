class ApplicationController < ActionController::Base
  protect_from_forgery

  def options
    set_access_control_headers
    head :ok
  end

  private
  def set_access_control_headers 
    headers['Access-Control-Allow-Origin'] = request.env['HTTP_ORIGIN']
    headers['Access-Control-Allow-Methods'] = 'POST, GET, DELETE'
    headers['Access-Control-Max-Age'] = '1000'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with'
  end
end
