class Account < ApplicationRecord
  has_many :sources
  has_many :items, through: :sources

  def domain_or_subdomain
    if subdomain.present?
      "#{subdomain}.#{ApplicationController.helpers.app_uri.host}" + (ApplicationController.helpers.app_uri.port ? ":#{ApplicationController.helpers.app_uri.port}" : "")
    else
      domain
    end
  end

  def url
    "//#{domain_or_subdomain}"
  end
end
