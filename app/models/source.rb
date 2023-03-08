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
#  account_id :uuid             not null
#
# Indexes
#
#  index_sources_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class Source < ApplicationRecord
  acts_as_tenant(:account)
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
