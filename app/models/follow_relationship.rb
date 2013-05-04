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
  attr_accessible :followed_id, :follower_id
end
