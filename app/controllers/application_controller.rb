class ApplicationController < ActionController::Base
  #Make sure that the id is decode before any action, since this is not done when run behind an apache webserver
  before_action do
    params[:id] = URI.decode(params[:id]) if params[:id].present?
  end
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

 end
