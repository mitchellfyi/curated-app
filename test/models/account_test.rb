# == Schema Information
#
# Table name: accounts
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

class AccountTest < ActiveSupport::TestCase
  test 'account cannot be created with a domain and/or subdomain' do
    assert_not Account.new.valid?
  end

  test 'account can be created with a domain and/or subdomain' do
    assert Account.new(domain: 'example123.com').valid?
    assert Account.new(domain: 'example123.com', subdomain: 'example123').valid?
    assert Account.new(subdomain: 'example123').valid?
  end

  test 'account domain must be unique' do
    assert_not Account.new(domain: 'example.com').valid?
  end

  test 'account subdomain must be unique' do
    assert_not Account.new(subdomain: 'example').valid?
  end

  test 'account host returns domain if present' do
    assert_equal 'example.com', Account.new(domain: 'example.com').host
    assert_equal 'example.com', Account.new(domain: 'example.com', subdomain: 'example').host
  end

  test 'account host returns subdomain if domain is not present' do
    assert_equal "example.#{ApplicationController.helpers.app_uri.host}", Account.new(subdomain: 'example').host
  end

  test 'account url returns host with protocol' do
    assert_equal '//example.com', Account.new(domain: 'example.com').url
    assert_equal "//example.#{ApplicationController.helpers.app_uri.host}", Account.new(subdomain: 'example').url
  end

  test 'account set_initial_tags adds tags' do
    account = Account.new
    account.set_initial_tags
    assert_equal I18n.t('tags'), account.tag_list
  end

  test 'account set_initial_tags does not add tags if tags are present' do
    account = Account.new(tag_list: ['example'])
    account.set_initial_tags
    assert_equal ['example'], account.tag_list
  end

  test 'account set_initial_sources adds sources' do
    mock = Minitest::Mock.new
    mock.expect :call, [Source.new, Source.new], [['example']]

    SourcesInitialService.stub :call, mock do
      account = Account.new(keyphrases: ['example'])
      account.set_initial_sources
      assert_equal 2, account.sources.size
    end

    assert_mock mock
  end

  test 'account set_initial_sources does not add sources if keyphrases are not present' do
    account = Account.new
    account.set_initial_sources
    assert_equal 0, account.sources.size
  end

  test 'account set_initial_sources adds sources even if sources are present' do
    mock = Minitest::Mock.new
    mock.expect :call, [Source.new, Source.new], [['example']]

    SourcesInitialService.stub :call, mock do
      account = Account.new(keyphrases: ['example'], sources: [Source.new])
      account.set_initial_sources
      assert_equal 3, account.sources.size
    end

    assert_mock mock
  end
end
