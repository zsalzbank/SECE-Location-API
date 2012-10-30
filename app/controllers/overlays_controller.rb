class OverlaysController < ApplicationController
  def index
    @overlays = Overlay.all()
  end

  def show
    @overlay = Overlay.find(params[:id])
  end

  def create
    @o = Overlay.new(params[:overlay])
    render :json => { :success => @o.save }
  end

  def img
    headers['Access-Control-Allow-Origin'] = request.headers['Referer']

    @overlay = Overlay.find(params[:id])
    send_data open(@overlay.img.path, 'rb').read, :filename => @overlay.img_file_name, :type => @overlay.img_content_type, :disposition => 'inline'
  end
end
