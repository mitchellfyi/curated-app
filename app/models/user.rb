class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable, :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable, :lockable, :trackable

  validates :email, presence: true, uniqueness: true
  validates :username, uniqueness: { case_sensitive: false }, if: -> { username.present? }

  before_save :ensure_username

  def ensure_username
    self.username = email.split('@')[0] if username.blank?
  end
end
