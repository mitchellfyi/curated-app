class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  before_action :set_tenant
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_user_location!, if: :storable_location?

  protected

    def authenticate_user!(opts = {})
      if user_signed_in?
        super
      else
        redirect_to(new_user_registration_url(subdomain: false, host: helpers.app_uri.host, port: helpers.app_uri.port), allow_other_host: true)
      end
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
      devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
    end

    def after_sign_in_path_for(resource_or_scope)
      stored_location_for(resource_or_scope) || super
    end

  private

    def set_tenant
      current_account = Account.where(subdomain: request.subdomain).or(Account.where(domain: request.domain)).first
      set_current_tenant(current_account)

      if current_tenant.nil? && !devise_controller?
        redirect_to(accounts_url(subdomain: false, host: helpers.app_uri.host, port: helpers.app_uri.port), allow_other_host: true)
      end
    end

    def storable_location?
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr? 
    end

    def store_user_location!
      store_location_for(:user, request.fullpath)
    end
end
