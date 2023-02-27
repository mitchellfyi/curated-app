require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'user cannot be created without email' do
    assert_not User.new.valid?
  end

  test 'user cannot be created without password' do
    assert_not User.new(email: 'test123456@example.com').valid?
  end

  test 'user can be created with email and password' do
    assert User.new(email: 'test123456@example.com', password: 'example').valid?
  end

  test 'user email is unique' do
    assert_not User.new(email: 'test123@example.com').valid?
  end

  test 'downcase_email downcases email' do
    user = User.new(email: 'TEST123456@EXAMPLE.COM')
    user.downcase_email
    assert_equal 'test123456@example.com', user.email
  end

  test 'set_username sets username to first part of email' do
    user = User.new(email: 'test123456@example.com')
    user.set_username
    assert_equal 'test123456', user.username
  end
end
