# == Schema Information
#
# Table name: sources
#
#  id         :uuid             not null, primary key
#  fetched_at :datetime
#  keyphrases :text             default([]), is an Array
#  name       :string
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  collection_id :uuid             not null
#
# Indexes
#
#  index_sources_on_collection_id  (collection_id)
#
# Foreign Keys
#
#  fk_rails_...  (collection_id => collections.id)
#
class Source < ApplicationRecord
  acts_as_tenant(:collection)
  acts_as_taggable_on(:tags)

  has_many :items

  validates_uniqueness_to_tenant :url
  validates :url, presence: true

  scope :ready_to_fetch, -> { where('fetched_at IS NULL OR fetched_at < ?', 1.hour.ago) }
  scope :has_new_items, -> { where('new_items_at IS NOT NULL && new_items_at > fetched_at') }

  def fetch!
    update(fetched_at: Time.now)
    update(new_items_at: Time.now)
  end
end
