require 'test_helper'

class SourcesInitialServiceTest < ActiveSupport::TestCase
  test 'per_keyphrase_template returns valid source attributes' do
    service = SourcesInitialService.new
    assert service.per_keyphrase_template.any?

    service.per_keyphrase_template.each do |attributes|
      assert accounts(:example).sources.new(attributes).valid?
    end
  end

  test 'sources_per_keyphrase returns sources with keyphrases' do
    keyphrases = ['example 1', 'example 2']
    service = SourcesInitialService.new(keyphrases)
    sources_template_size = service.per_keyphrase_template.size
    assert_equal sources_template_size * keyphrases.size, service.sources_per_keyphrase.size

    service.sources_per_keyphrase.each do |source|
      assert accounts(:example).sources.new(source.attributes).valid?
      assert source.to_json.include?(keyphrases.first) || source.to_json.include?(keyphrases.last)
    end
  end

  test 'sources_per_keyphrase escapes characters in keyphrases' do
    keyphrases = ['!@#$%^&*()_+{}|:"<>?[];']
    service = SourcesInitialService.new(keyphrases)

    service.stub :per_keyphrase_template, [{ name: '${keyphrase}' }] do
      source = service.sources_per_keyphrase.first
      assert_not source.name.include?('!@#$%^&*()_+{}|:"<>?[];')
    end
  end

  test 'sources_per_keyphrase escapes html in keyphrases' do
    keyphrases = ['<script>']
    service = SourcesInitialService.new(keyphrases)

    service.stub :per_keyphrase_template, [{ name: '${keyphrase}' }] do
      source = service.sources_per_keyphrase.first
      assert_not source.name.include?('<script>')
    end
  end

  test 'sources_per_keyphrase encodes keyphrases' do
    keyphrases = ['example 1 !@#$%^&*()_+{}|:"<>?[];']
    service = SourcesInitialService.new(keyphrases)

    service.stub :per_keyphrase_template, [{ name: '${keyphrase.encode}' }] do
      source = service.sources_per_keyphrase.first
      assert source.name.include?('example+1+')
      assert_not source.name.include?('!@#$%^&*()_+{}|:"<>?[];')
    end
  end

  test 'sources_per_keyphrase parameterizes keyphrases' do
    keyphrases = ['example 1 !@#$%^&*()_+{}|:"<>?[];']
    service = SourcesInitialService.new(keyphrases)

    service.stub :per_keyphrase_template, [{ name: '${keyphrase.parameterize}' }] do
      source = service.sources_per_keyphrase.first
      assert source.name.include?('example-1-')
      assert_not source.name.include?('!@#$%^&*()_+{}|:"<>?[];')
    end
  end

  test 'keyphrases_required_template returns valid source attributes' do
    service = SourcesInitialService.new
    assert service.keyphrases_required_template.any?

    service.keyphrases_required_template.each do |attributes|
      assert accounts(:example).sources.new(attributes).valid?
    end
  end

  test 'sources_with_keyphrases returns sources with keyphrases' do
    keyphrases = ['example 1', 'example 2']
    service = SourcesInitialService.new(keyphrases)
    assert_equal service.keyphrases_required_template.size, service.sources_with_keyphrases.size

    service.sources_with_keyphrases.each do |source|
      assert accounts(:example).sources.new(source.attributes).valid?
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
