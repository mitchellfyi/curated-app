module ApplicationHelper
  def app_uri
    host = Rails.application.credentials.dig(:app, :host)
    scheme = 'https'
    
    if Rails.env.development?
      host = "#{host.split('.').first}.localhost" 
      scheme = 'http'
      port = 5000
    end

    URI::Generic.build(scheme: scheme, host: host, port: port)
  end
end
