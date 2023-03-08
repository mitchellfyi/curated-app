require 'test_helper'

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @collection = collections(:example)
  end

  test 'should get index' do
    get collections_url
    assert_response :success
  end

  test 'should redirect to sign up when trying to get new when logged out' do
    get new_collection_url
    assert_redirected_to new_user_registration_url
  end

  test 'should get new when any user is logged in' do
    sign_in users(:example)
    get new_collection_url
    assert_response :success
  end

  test 'should redirect to sign up when trying to create when logged out' do
    post collections_url, params: { collection: { domain: 'example123.com' } }
    assert_redirected_to new_user_registration_url
  end

  test 'should create collection when any user is logged in' do
    sign_in users(:example)
    assert_difference('Collection.count') do
      post collections_url, params: { collection: { domain: 'example123.com' } }
    end

    collection = Collection.find_by_domain('example123.com')
    assert_redirected_to collection_url(collection)
    assert users(:example).has_role?(:owner, collection)
    assert users(:example).has_role?(:staff, collection)
  end

  test 'should show collection' do
    get collection_url(@collection)
    assert_redirected_to @collection.url
  end

  test 'should redirect to sign up when trying to edit when logged out' do
    get edit_collection_url(@collection)
    assert_redirected_to new_user_registration_url
  end

  test 'should redirect to root when trying to edit without permission' do
    sign_in users(:example)
    get edit_collection_url(@collection)
    assert_redirected_to root_url
  end

  test 'should get edit with permission' do
    sign_in users(:example)
    users(:example).add_role(:staff, @collection)
    get edit_collection_url(@collection)
    assert_response :success

    users(:example).remove_role(:staff, @collection)
    users(:example).add_role(:owner, @collection)
    get edit_collection_url(@collection)
    assert_response :success
  end

  test 'should redirect to sign up when trying to update when logged out' do
    patch collection_url(@collection), params: { collection: { name: 'example' } }
    assert_redirected_to new_user_registration_url
  end

  test 'should redirect to root when trying to update without permission' do
    sign_in users(:example)
    patch collection_url(@collection), params: { collection: { name: 'example' } }
    assert_redirected_to root_url
  end

  test 'should update with permission' do
    sign_in users(:example)
    users(:example).add_role(:staff, @collection)
    patch collection_url(@collection), params: { collection: { name: 'example' } }
    assert_redirected_to edit_collection_url(@collection)

    users(:example).remove_role(:staff, @collection)
    users(:example).add_role(:owner, @collection)
    patch collection_url(@collection), params: { collection: { name: 'example' } }
    assert_redirected_to edit_collection_url(@collection)
  end

  test 'should redirect to sign up when trying to destroy when logged out' do
    delete collection_url(@collection)
    assert_redirected_to new_user_registration_url
  end

  test 'should redirect to root when trying to destroy without permission' do
    sign_in users(:example)
    assert_difference('Collection.count', 0) do
      delete collection_url(@collection)
    end
    assert_redirected_to root_url

    users(:example).add_role(:staff, @collection)
    assert_difference('Collection.count', 0) do
      delete collection_url(@collection)
    end
    assert_redirected_to root_url
  end

  test 'should destroy with permission' do
    sign_in users(:example)
    users(:example).add_role(:owner, @collection)
    assert_difference('Collection.count', -1) do
      delete collection_url(@collection)
    end

    assert_redirected_to root_url
  end
end
