class Item < ApplicationRecord
  acts_as_tenant(:account)
  
  belongs_to :source, optional: true
end
