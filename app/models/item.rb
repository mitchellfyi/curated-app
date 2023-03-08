# == Schema Information
#
# Table name: items
#
#  id         :uuid             not null, primary key
#  content    :text
#  fetched_at :datetime
#  title      :string
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :uuid             not null
#  source_id  :uuid
#
# Indexes
#
#  index_items_on_account_id  (account_id)
#  index_items_on_source_id   (source_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (source_id => sources.id)
#
class Item < ApplicationRecord
  acts_as_tenant(:account)
  acts_as_taggable_on(:tags)
  
  belongs_to :source, optional: true

  scope :ready_to_fetch, -> { where('fetched_at IS NULL OR fetched_at < ?', 30.days.ago) }

  def fetch!
    update(fetched_at: Time.now)
  end
end
