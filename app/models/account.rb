class Account < ApplicationRecord
  resourcify

  has_many :sources
  has_many :items, through: :sources

  def domain_or_subdomain
    if subdomain.present?
      port = ApplicationController.helpers.app_uri.port

      "#{subdomain}.#{ApplicationController.helpers.app_uri.host}" + (port ? ":#{port}" : '')
    else
      domain
    end
  end

  def url
    "//#{domain_or_subdomain}"
  end
end
