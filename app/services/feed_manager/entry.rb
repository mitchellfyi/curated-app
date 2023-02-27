# frozen_string_literal: true

module FeedManager
  class Entry
    def initialize(entry, source)
      @entry = entry
      @source = source
    end

    def attributes
      slice(%w[url title image summary content author published_at guid fetched_source_entry tag_list])
    end

    def valid?
      title.present? && url.present?
    end

    def matches_keyphrases?
      @source.keyphrases.blank? ||
        KeyphraseMatchingService.matches?(@source.keyphrases, title) ||
        KeyphraseMatchingService.matches?(@source.keyphrases, [summary, content].join(' '))
    end

    def tag_list
      tags = @source.tag_list

      if question?
        tags.push('Question')
      end

      tags
    end

    def url
      @entry.url
    end

    def title
      @entry.title
    end

    def image
      @entry.image
    end

    def summary
      @entry.summary
    end

    def content
      @entry.content
    end

    def author
      @entry.author
    end

    def published_at
      @entry.published || @entry.updated || Time.now.utc
    end

    def categories
      @entry.categories
    end

    def guid
      url
    end

    def feed_guid
      @entry.id
    end

    def question?
      title.end_with?('?')
    end

    def creator_id
      @source.id
    end

    def creator_type
      @source.class
    end

    def scope_id
      @source.scope_id
    end

    def scope_type
      @source.scope_type
    end

    def visibility
      :open
    end

    def status
      :published
    end

    def fetched_source_entry
      entry
    end
  end
end
