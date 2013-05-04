# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  has_secure_password

  attr_accessible :email, :name, :password, :password_confirmation
  has_many :microposts, dependent: :destroy
  has_many :follow_relationships, foreign_key: "follower_id"
  has_many :followed_users, through: :follow_relationships, source: :followed
  has_many :reverse_follow_relationships, foreign_key: "followed_id",
                                          class_name: "FollowRelationship",
                                          dependent: :destroy
  has_many :followers, through: :reverse_follow_relationships, source: :follower

  before_save { |user| user.email = email.downcase }
  before_save { |user| user.remember_token = SecureRandom.urlsafe_base64 }

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 } # presence verified by presence of password_digest
  validates :password_confirmation, presence: true

  def feed
    microposts
  end

  def following?(other_user)
    not follow_relationships.find_by_followed_id(other_user.id).nil?
  end

  def follow!(other_user)
    follow_relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    follow_relationships.find_by_followed_id(other_user.id).destroy
  end
end
