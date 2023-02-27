require 'test_helper'

class KeyphraseMatchingServiceTest < ActiveSupport::TestCase
  test 'match keyphrases by word boundary' do
    service = KeyphraseMatchingService.new

    service.keyphrases = ['wordboundary']
    service.contents = 'wordboundary'
    assert service.matches?
    service.contents = 'wordboundary test'
    assert service.matches?
    service.contents = 'test wordboundary'
    assert service.matches?
    service.contents = 'test wordboundary test'
    assert service.matches?

    service.contents = 'word boundary'
    assert_not service.matches?
    service.contents = 'word boundarytest'
    assert_not service.matches?
    service.contents = 'testword boundary'
    assert_not service.matches?
    service.contents = 'testword boundarytest'
    assert_not service.matches?
  end

  test 'match keyphrases multi-word' do
    service = KeyphraseMatchingService.new

    service.keyphrases = ['(simple|easy)']
    service.contents = 'simple'
    assert service.matches?
    service.contents = 'easy'
    assert service.matches?
    service.contents = 'simple easy'
    assert service.matches?
    service.contents = 'simple test easy'
    assert service.matches?
    service.contents = 'test simple test easy'
    assert service.matches?

    service.contents = 'neither'
    assert_not service.matches?
    service.contents = 'simpleasy'
    assert_not service.matches?

    service.keyphrases = ['end(ing|ly)']
    service.contents = 'ending'
    assert service.matches?
    service.contents = 'endly'

    service.contents = 'end'
    assert_not service.matches?
    service.contents = 'endlynot'
    assert_not service.matches?
  end

  test 'match keyphrases by case' do
    service = KeyphraseMatchingService.new

    service.keyphrases = ['CaSe']
    service.contents = 'cAsE'
    assert service.matches?
  end

  test 'keyphrases empty' do
    service = KeyphraseMatchingService.new

    assert service.matches?

    service.contents = 'test'
    assert service.matches?

    service.keyphrases = []
    assert service.matches?

    service.keyphrases = nil
    assert service.matches?
  end

  test 'contents empty' do
    service = KeyphraseMatchingService.new

    assert service.matches?

    service.keyphrases = ['test']
    assert_not service.matches?

    service.contents = ''
    assert_not service.matches?

    service.contents = nil
    assert_not service.matches?
  end
end
