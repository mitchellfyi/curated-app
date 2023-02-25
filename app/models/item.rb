class Item < ApplicationRecord
  acts_as_tenant(:account)
  acts_as_taggable_on(:tags)
  
  belongs_to :source, optional: true
end
