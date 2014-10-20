module ApplicationHelper
  
  def javascript(*files)
    content_for(:footer_js) { javascript_include_tag(*files) }
  end
  
end
