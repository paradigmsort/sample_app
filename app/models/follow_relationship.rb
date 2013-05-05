# == Schema Information
#
# Table name: follow_relationships
#
#  id          :integer          not null, primary key
#  follower_id :integer
#  followed_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class FollowRelationship < ActiveRecord::Base
  attr_accessible :followed_id
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validate :different_users

  private
    def different_users
      errors.add(:followed_id, "can't be the same as follower") if follower_id == followed_id
    end
end
