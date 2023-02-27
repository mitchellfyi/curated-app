require 'test_helper'

class SourcesInitialServiceTest < ActiveSupport::TestCase
  setup do
    ActsAsTenant.current_tenant = accounts(:example)
  end

  test 'keyphrases_escaped escapes characters in keyphrases' do
    keyphrase = '!@#$%^&*()_+{}|:"<>?[];'
    service = SourcesInitialService.new([keyphrase])
    assert_not service.keyphrases_escaped.include?(keyphrase)
  end

  test 'keyphrases_escaped escapes html in keyphrases' do
    keyphrase = '<script>'
    service = SourcesInitialService.new([keyphrase])
    assert_not service.keyphrases_escaped.include?(keyphrase)
  end

  test 'per_keyphrase_template returns valid source attributes' do
    service = SourcesInitialService.new
    assert service.per_keyphrase_template.any?

    service.per_keyphrase_template.each do |attributes|
      assert Source.new(attributes).valid?
    end
  end

  test 'replace_keyphrases replaces keyphrases' do
    keyphrase = 'example'
    service = SourcesInitialService.new
    assert_equal service.replace_keyphrases('${keyphrase}', keyphrase), keyphrase
  end

  test 'replace_keyphrases encodes keyphrases' do
    keyphrase = 'example 1 !@#$%^&*()_+{}|:"<>?[];'
    service = SourcesInitialService.new
    assert service.replace_keyphrases('${keyphrase.encode}', keyphrase).include?('example+1+')
  end

  test 'replace_keyphrases parameterizes keyphrases' do
    keyphrase = 'example 1 !@#$%^&*()_+{}|:"<>?[];'
    service = SourcesInitialService.new
    assert service.replace_keyphrases('${keyphrase.parameterize}', keyphrase).include?('example-1-')
  end

  test 'sources_per_keyphrase returns sources with keyphrases' do
    keyphrases = ['example 1', 'example 2']
    service = SourcesInitialService.new(keyphrases)
    sources_template_size = service.per_keyphrase_template.size
    assert_equal sources_template_size * keyphrases.size, service.sources_per_keyphrase.size

    service.sources_per_keyphrase.each do |source|
      assert Source.new(source.attributes).valid?
      assert source.to_json.include?(keyphrases.first) || source.to_json.include?(keyphrases.last)
    end
  end

  test 'keyphrases_required_template returns valid source attributes' do
    service = SourcesInitialService.new
    assert service.keyphrases_required_template.any?

    service.keyphrases_required_template.each do |attributes|
      assert Source.new(attributes).valid?
    end
  end

  test 'sources_with_keyphrases returns sources with keyphrases' do
    keyphrases = ['example 1', 'example 2']
    service = SourcesInitialService.new(keyphrases)
    assert_equal service.keyphrases_required_template.size, service.sources_with_keyphrases.size

    service.sources_with_keyphrases.each do |source|
      assert Source.new(source.attributes).valid?
      assert_equal source.keyphrases, keyphrases
    end
  end

  test 'call returns sources with keyphrases' do
    keyphrases = ['example 1', 'example 2']
    service = SourcesInitialService.new(keyphrases)
    sources = SourcesInitialService.call(keyphrases)
    assert_equal sources.size, service.sources_per_keyphrase.size + service.sources_with_keyphrases.size
  end

  test 'call returns nil if keyphrases are not present' do
    assert_nil SourcesInitialService.call
  end

  test 'call does not return duplicates' do
    keyphrases = ['example', 'example']
    sources = SourcesInitialService.call(keyphrases)
    assert_equal sources.size, sources.uniq.size
  end
end
