# frozen_string_literal: true

class SourcesInitialService < ApplicationService
  attr_accessor :keyphrases

  def initialize(keyphrases = [])
    super()

    @keyphrases = keyphrases
  end

  def per_keyphrase_template
    @per_keyphrase_template ||= YAML.load_file(File.join(Rails.root, 'db/seeds/sources/per_keyphrase.yml'))
  end

  def sources_per_keyphrase
    results = []

    @keyphrases.each do |keyphrase|
      keyphrase = ActionController::Base.helpers.sanitize(keyphrase).to_json[1..-2]
      template_json = per_keyphrase_template
                      .to_json
                      .gsub('${keyphrase}', keyphrase)
                      .gsub('${keyphrase.encode}', CGI.escape(keyphrase))
                      .gsub('${keyphrase.parameterize}', keyphrase.parameterize)

      JSON.parse(template_json).each do |attributes|
        results.push(Source.new(attributes))
      end
    end

    results
  end

  def keyphrases_required_template
    @keyphrases_required_template ||= YAML.load_file(File.join(Rails.root, 'db/seeds/sources/keyphrases_required.yml'))
  end

  def sources_with_keyphrases
    keyphrases_required_template.map do |attributes|
      attributes[:keyphrases] = keyphrases

      Source.new(attributes)
    end
  end

  def call
    return if @keyphrases.blank?

    []
      .concat(sources_per_keyphrase)
      .concat(sources_with_keyphrases)
      .uniq
  end
end
