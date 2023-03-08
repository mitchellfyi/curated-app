# == Schema Information
#
# Table name: collections
#
#  id         :uuid             not null, primary key
#  domain     :string
#  keyphrases :text             default([]), is an Array
#  name       :string
#  subdomain  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  test 'collection cannot be created without a domain and/or subdomain' do
    assert_not Collection.new.valid?
  end

  test 'collection can be created with a domain and/or subdomain' do
    assert Collection.new(domain: 'example.domain').valid?
    assert Collection.new(domain: 'example.domain', subdomain: 'example-subdomain').valid?
    assert Collection.new(subdomain: 'example-subdomain').valid?
  end

  test 'collection domain must be unique' do
    assert_not Collection.new(domain: collections.first.domain).valid?
  end

  test 'collection subdomain must be unique' do
    assert_not Collection.new(subdomain: collections.first.subdomain).valid?
  end

  test 'collection host returns domain if present' do
    assert_equal 'example.domain', Collection.new(domain: 'example.domain').host
    assert_equal 'example.domain', Collection.new(domain: 'example.domain', subdomain: 'example-subdomain').host
  end

  test 'collection host returns subdomain if domain is not present' do
    assert_equal Collection.new(subdomain: 'example-subdomain').host,
                 "example-subdomain.#{ApplicationController.helpers.app_uri.host}#{ApplicationController.helpers.app_uri.port ? ":#{ApplicationController.helpers.app_uri.port}" : ''}"
  end

  test 'collection url returns host with protocol' do
    assert_equal Collection.new(domain: 'example.domain').url, '//example.domain'
    assert_equal Collection.new(subdomain: 'example-subdomain').url,
                 "//example-subdomain.#{ApplicationController.helpers.app_uri.host}#{ApplicationController.helpers.app_uri.port ? ":#{ApplicationController.helpers.app_uri.port}" : ''}"
  end

  test 'collection set_initial_tags adds tags' do
    collection = Collection.new
    collection.set_initial_tags
    assert_equal I18n.t('tags'), collection.tag_list
  end

  test 'collection set_initial_tags does not add tags if tags are present' do
    collection = Collection.new(tag_list: ['example-tag'])
    collection.set_initial_tags
    assert_equal ['example-tag'], collection.tag_list
  end

  test 'collection set_initial_sources adds sources' do
    mock = Minitest::Mock.new
    mock.expect :call, [Source.new, Source.new], [['example-keyphrase']]

    SourcesInitialService.stub :call, mock do
      collection = Collection.new(keyphrases: ['example-keyphrase'])
      collection.set_initial_sources
      assert_equal 2, collection.sources.size
    end

    assert_mock mock
  end

  test 'collection set_initial_sources does not add sources if keyphrases are not present' do
    collection = Collection.new
    collection.set_initial_sources
    assert_equal 0, collection.sources.size
  end

  test 'collection set_initial_sources adds sources even if sources are present' do
    mock = Minitest::Mock.new
    mock.expect :call, [Source.new, Source.new], [['example-keyphrase']]

    SourcesInitialService.stub :call, mock do
      collection = Collection.new(keyphrases: ['example-keyphrase'], sources: [Source.new])
      collection.set_initial_sources
      assert_equal 3, collection.sources.size
    end

    assert_mock mock
  end
end
