class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  set_current_tenant_through_filter

  before_action :set_tenant
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_user_location!, if: :storable_location?

  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  protected

  def authenticate_user!(opts = {})
    if user_signed_in?
      super
    else
      redirect_to(
        new_user_registration_url(subdomain: false, host: helpers.app_uri.host,
                                  port: helpers.app_uri.port), allow_other_host: true
      )
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

    return unless current_tenant.nil? && !devise_controller?

    redirect_to(accounts_url(subdomain: false, host: helpers.app_uri.host, port: helpers.app_uri.port),
                allow_other_host: true)
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_back(fallback_location: root_path)
  end
end
