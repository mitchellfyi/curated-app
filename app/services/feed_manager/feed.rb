# frozen_string_literal: true

module FeedManager
  class Feed
    def initialize(document, source)
      @document = document
      @source = source
    end

    def parsed
      @parsed ||= Feedjira.parse(@document)
    end

    def valid?
      entries&.any?
    end

    def meta
      FeedManager::Meta.new(parsed)
    end

    def entries
      parsed
        .entries
        .map { |entry| FeedManager::Entry.new(entry, @source) }
        .select(&:valid?)
        .select(&:matches_keyphrases?)
        .uniq(&:guid)
        .sort_by(&:published_at)
        .reverse
    end
  end
end
