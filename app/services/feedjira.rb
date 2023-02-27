# frozen_string_literal: true

module Feedjira
  module FeedEntryUtilities
    def parse_datetime(string)
      DateTime.parse(string).feed_utils_to_gm_time
    rescue StandardError
      Chronic.time_class = Time.zone
      Chronic.parse(string, context: :past)
    end
  end
end
