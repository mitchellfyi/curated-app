class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  before_action :set_tenant

  private

  def set_tenant
    current_account = Account.where(subdomain: request.subdomain).or(Account.where(domain: request.domain)).first
    set_current_tenant(current_account)

    if current_tenant.nil?
      redirect_to(new_account_url(subdomain: false, host: helpers.app_uri.host, port: helpers.app_uri.port), allow_other_host: true)
    end
  end
end
