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
#  collection_id :uuid             not null
#  source_id  :uuid
#
# Indexes
#
#  index_items_on_collection_id  (collection_id)
#  index_items_on_source_id   (source_id)
#
# Foreign Keys
#
#  fk_rails_...  (collection_id => collections.id)
#  fk_rails_...  (source_id => sources.id)
#
require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  setup do
    ActsAsTenant.current_tenant = collections(:current_tenant)
  end
end
