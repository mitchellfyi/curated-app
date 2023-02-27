class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable, :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable, :lockable, :trackable
  rolify

  accepts_nested_attributes_for :roles, allow_destroy: true, reject_if: :all_blank

  validates :email, presence: true, uniqueness: true
  validates :username, uniqueness: { case_sensitive: false }, if: -> { username.present? }

  before_save :set_username

  def set_username
    self.username = email.split('@')[0] if username.blank?
  end
end
