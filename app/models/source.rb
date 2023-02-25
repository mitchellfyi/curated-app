class Source < ApplicationRecord
  acts_as_tenant(:account)
  acts_as_taggable_on(:tags)

  has_many :items

  validates_uniqueness_to_tenant :url

  def fetch!
    update(fetched_at: Time.now)
  end
end
