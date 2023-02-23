class Item < ApplicationRecord
  belongs_to :source, optional: true
end
