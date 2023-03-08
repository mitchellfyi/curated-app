# == Schema Information
#
# Table name: collections
#
#  id         :uuid             not null, primary key
#  domain     :string
#  keyphrases :text             default([]), is an Array
#  name       :string
#  subdomain  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Collection < ApplicationRecord
  resourcify
  acts_as_taggable_on :tags

  has_many :sources
  has_many :items, through: :sources

  accepts_nested_attributes_for :sources, allow_destroy: true, reject_if: :all_blank

  validates :domain, presence: true, uniqueness: true, unless: :subdomain?
  validates :subdomain, presence: true, uniqueness: true, unless: :domain?

  before_save :set_initial_tags, if: proc { tag_list.empty? }
  before_save :set_initial_sources, if: proc { keyphrases.any? }

  def host
    if domain.present?
      domain
    else
      port = ApplicationController.helpers.app_uri.port

      "#{subdomain}.#{ApplicationController.helpers.app_uri.host}" + (port ? ":#{port}" : '')
    end
  end

  def url
    "//#{host}"
  end

  def set_initial_tags
    return unless tag_list.empty?

    self.tag_list += I18n.t('tags')
  end

  def set_initial_sources
    return unless keyphrases.any?

    self.sources += SourcesInitialService.call(keyphrases)
  end

  def create_items_from_source!; end
end
