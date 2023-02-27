# frozen_string_literal: true

class KeyphraseMatchingService < ApplicationService
  attr_accessor :keyphrases, :contents

  def self.matches?(...)
    new(...).matches?
  end

  def initialize(keyphrases = [], contents = '')
    super()

    @keyphrases = keyphrases
    @contents = contents
  end

  def matches?
    @keyphrases.blank? ||
      @keyphrases.any? do |keyphrase|
        keyphrase = "\\b#{keyphrase}\\b"
        Regexp.new(keyphrase, true).match?(@contents)
      end
  end
end
