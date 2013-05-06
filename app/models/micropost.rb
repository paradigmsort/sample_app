# == Schema Information
#
# Table name: microposts
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Micropost < ActiveRecord::Base
  attr_accessible :content
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  default_scope order: 'microposts.created_at DESC'

  AT_REPLY_REGEX = /\A@(\d+)/
  before_save do |micropost|
    AT_REPLY_REGEX.match(micropost.content) do |m|
      unless m.nil? then
        micropost.in_reply_to = m[1].to_i
      end
    end
  end

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM follow_relationships
                         WHERE follower_id = :user_id"
    where("(user_id IN (#{followed_user_ids})
            AND (in_reply_to IS NULL OR in_reply_to IN (#{followed_user_ids})))
           OR user_id = :user_id
           OR in_reply_to = :user_id", user_id: user.id)
  end
end
