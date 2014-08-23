class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :exception
  
  def initialize
    super
    init_html_variables
    init_lang_variables
  end
  
  protected
  
  def init_html_variables
    Var.where(:active => true).each do |var|
      instance_variable_set('@' + var.name, var.value)
    end
    @page_lang_cls = determine_lang
    @page_robots = Rails.env.production? ? 'index, follow' : 'noindex, nofollow'
    @device_cls = determine_device
    @is_logged_in_cls = determine_login_status

  end
  
  def init_lang_variables
    Lang.where(:active => true).each do |var|
      instance_variable_set('@' + var.name, var.value)
    end
  end
  
  def determine_lang
    'en'
  end
  
  def determine_device
    'desktop'
  end
  
  def determine_login_status
    'not-logged-in'
  end
  
  private
  
end
