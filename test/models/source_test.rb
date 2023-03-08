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
require 'test_helper'

class SourceTest < ActiveSupport::TestCase
  setup do
    ActsAsTenant.current_tenant = collections(:current_tenant)
  end

  test 'source cannot be created without a url' do
    assert_not Source.new.valid?
    assert_not ActsAsTenant.current_tenant.sources.new.valid?
  end

  test 'source cannot be created without a unique url' do
    existing_url = sources(:current_tenant_source).url

    assert_not Source.new(url: existing_url).valid?
    assert_not ActsAsTenant.current_tenant.sources.new(url: existing_url).valid?
  end

  test 'source can be created with a url' do
    assert Source.new(url: 'http://example.domain').valid?
    assert ActsAsTenant.current_tenant.sources.new(url: 'http://example.com').valid?
  end

  test 'source can be created with a url and keyphrases' do
    assert (source = Source.new(url: 'http://example.domain', keyphrases: ['example-keyphrase'])).valid?
    assert_equal source.keyphrases, ['example-keyphrase']
    assert ActsAsTenant.current_tenant.sources.new(url: 'http://example.com', keyphrases: ['example-keyphrase']).valid?
  end

  test 'source can be created with a url and tags' do
    assert (source = Source.new(url: 'http://example.domain', tag_list: ['example-tag'])).valid?
    assert_equal source.tag_list, ['example-tag']
    assert ActsAsTenant.current_tenant.sources.new(url: 'http://example.com', tag_list: ['example-tag']).valid?
  end

  test 'source can be created with a url, keyphrases and tags' do
    assert Source.new(url: 'http://example.domain', keyphrases: ['example-keyphrase'], tag_list: ['example-tag']).valid?
    assert ActsAsTenant.current_tenant.sources.new(url: 'http://example.com', keyphrases: ['example-keyphrase'],
                                                   tag_list: ['example-tag']).valid?
  end
end
