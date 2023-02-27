require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @account = accounts(:example)
  end

  test 'should get index' do
    get accounts_url
    assert_response :success
  end

  test 'should redirect to sign up when trying to get new when logged out' do
    get new_account_url
    assert_redirected_to new_user_registration_url
  end

  test 'should get new when any user is logged in' do
    sign_in users(:example)
    get new_account_url
    assert_response :success
  end

  test 'should redirect to sign up when trying to create when logged out' do
    post accounts_url, params: { account: { domain: 'example123.com' } }
    assert_redirected_to new_user_registration_url
  end

  test 'should create account when any user is logged in' do
    sign_in users(:example)
    assert_difference('Account.count') do
      post accounts_url, params: { account: { domain: 'example123.com' } }
    end

    account = Account.find_by_domain('example123.com')
    assert_redirected_to account_url(account)
    assert users(:example).has_role?(:owner, account)
    assert users(:example).has_role?(:staff, account)
  end

  test 'should show account' do
    get account_url(@account)
    assert_redirected_to @account.url
  end

  test 'should redirect to sign up when trying to edit when logged out' do
    get edit_account_url(@account)
    assert_redirected_to new_user_registration_url
  end

  test 'should redirect to root when trying to edit without permission' do
    sign_in users(:example)
    get edit_account_url(@account)
    assert_redirected_to root_url
  end

  test 'should get edit with permission' do
    sign_in users(:example)
    users(:example).add_role(:staff, @account)
    get edit_account_url(@account)
    assert_response :success

    users(:example).remove_role(:staff, @account)
    users(:example).add_role(:owner, @account)
    get edit_account_url(@account)
    assert_response :success
  end

  test 'should redirect to sign up when trying to update when logged out' do
    patch account_url(@account), params: { account: { name: 'example' } }
    assert_redirected_to new_user_registration_url
  end

  test 'should redirect to root when trying to update without permission' do
    sign_in users(:example)
    patch account_url(@account), params: { account: { name: 'example' } }
    assert_redirected_to root_url
  end

  test 'should update with permission' do
    sign_in users(:example)
    users(:example).add_role(:staff, @account)
    patch account_url(@account), params: { account: { name: 'example' } }
    assert_redirected_to edit_account_url(@account)

    users(:example).remove_role(:staff, @account)
    users(:example).add_role(:owner, @account)
    patch account_url(@account), params: { account: { name: 'example' } }
    assert_redirected_to edit_account_url(@account)
  end

  test 'should redirect to sign up when trying to destroy when logged out' do
    delete account_url(@account)
    assert_redirected_to new_user_registration_url
  end

  test 'should redirect to root when trying to destroy without permission' do
    sign_in users(:example)
    assert_difference('Account.count', 0) do
      delete account_url(@account)
    end
    assert_redirected_to root_url

    users(:example).add_role(:staff, @account)
    assert_difference('Account.count', 0) do
      delete account_url(@account)
    end
    assert_redirected_to root_url
  end

  test 'should destroy with permission' do
    sign_in users(:example)
    users(:example).add_role(:owner, @account)
    assert_difference('Account.count', -1) do
      delete account_url(@account)
    end

    assert_redirected_to root_url
  end
end
