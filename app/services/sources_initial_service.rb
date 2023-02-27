# frozen_string_literal: true

class SourcesInitialService < ApplicationService
  attr_accessor :keyphrases

  def initialize(keyphrases = [])
    super()

    @keyphrases = keyphrases
  end

  def per_keyphrase_template
    @per_keyphrase_template ||= YAML.load_file(File.join(Rails.root, 'db/seeds/sources/per_keyphrase.yml')).to_json
  end

  def per_keyphrase_sources
    results = []

    @keyphrases.each do |keyphrase|
      template_json = @per_keyphrase_template
                      .gsub('${keyword}', keyphrase)
                      .gsub('${keyword.encode}', keyphrase.parameterize(separator: '+'))
                      .gsub('${keyword.parameterize}', keyphrase.parameterize)

      results.concat(JSON.parse(template_json).map(&:deep_symbolize_keys!))
    end

    results
  end

  def keyphrases_required_template
    @keyphrases_required_template ||= YAML.load_file(File.join(Rails.root, 'db/seeds/sources/keyphrases_required.yml'))
  end

  def keyphrases_required_sources
    @keyphrases_required_template.map do |source|
      source[:keyphrases] = keyphrases
      source
    end
  end

  def call
    return if @keyphrases.blank?

    per_keyphrase_sources.concat(keyphrases_required_sources).uniq.map(&:deep_symbolize_keys!)
  end
end
