require 'test_helper'

class FeedManagerTest < ActiveSupport::TestCase
  setup do
    @rss = File.read(Rails.root.join('test/fixtures/files/rss.xml'))
  end

  test 'should create a parsed feed' do
    feed = FeedManager::Feed.new(@rss, Source.new)
    assert(feed.parsed)
  end

  test 'should have a valid feed' do
    feed = FeedManager::Feed.new(@rss, Source.new)
    assert(feed.valid?)
  end

  test 'should have a meta' do
    feed = FeedManager::Feed.new(@rss, Source.new)
    assert(feed.meta)
  end

  test 'should have entries' do
    feed = FeedManager::Feed.new(@rss, Source.new)
    assert(feed.entries.any?)
    assert_equal(2, feed.entries.size)
  end

  test 'should have a valid entry' do
    feed = FeedManager::Feed.new(@rss, Source.new)
    assert(feed.entries.first.valid?)
  end

  test 'should have a matching entry' do
    feed = FeedManager::Feed.new(@rss, Source.new(keyphrases: ['example 1']))
    assert(feed.entries.first.matches_keyphrases?)
  end

  test 'should have unique entries' do
    feed = FeedManager::Feed.new(@rss + @rss, Source.new)
    assert_equal(2, feed.entries.size)
  end

  test 'should have sorted entries' do
    feed = FeedManager::Feed.new(@rss, Source.new)
    assert(feed.entries.first.published_at > feed.entries.last.published_at)
  end

  test 'should include a question' do
    feed = FeedManager::Feed.new(@rss, Source.new)
    assert(feed.entries.last.question?)
  end

  test 'should include a question tag' do
    feed = FeedManager::Feed.new(@rss, Source.new)
    assert(feed.entries.last.tag_list.any? { |tag| tag == 'Question' })
  end
end
