# frozen_string_literal: true

module FeedManager
  class Meta
    def initialize(feed)
      @feed = feed
    end

    def url
      @feed.url
    end

    def name
      @feed.name
    end

    def image
      @feed.image
    end

    def description
      @feed.description
    end

    def last_modified
      @feed.last_modified
    end

    def language
      @feed.language
    end

    def generator
      @feed.generator
    end
  end
end
