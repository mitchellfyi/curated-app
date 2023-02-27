# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  unlock_token           :string
#  username               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
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
