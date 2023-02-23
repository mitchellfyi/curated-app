class Source < ApplicationRecord
  has_many :items

  def fetch!
    update(fetched_at: Time.now)
  end
end
