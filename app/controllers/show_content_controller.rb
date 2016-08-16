class ShowContentController < ApplicationController

  include Blacklight::Base
  layout 'show_content'

  def show
    @response, @document = fetch  URI.decode(params[:id])
    render('content')
  end

end
