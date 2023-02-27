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

  def fetch_items!
    update(fetched_at: Time.now)
  end
end
