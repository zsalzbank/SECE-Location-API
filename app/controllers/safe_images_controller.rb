class SafeImagesController < ApplicationController
  def index
    @img = params[:image]

    headers['Access-Control-Allow-Origin'] = '*'
    render :text => 'data:' + @img.content_type + ';base64,' + ActiveSupport::Base64.encode64(open(@img.tempfile.path) { |io| io.read })
  end
end
