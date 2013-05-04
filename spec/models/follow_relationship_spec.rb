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

require 'spec_helper'

describe FollowRelationship do
  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }
  let(:relationship) { follower.follow_relationships.build(followed_id: followed.id) }

  subject { relationship }

  it { should be_valid }

  describe "attribute accessibility" do
    it "should not allow access to follower_id" do
      expect do
        FollowRelationship.new(follower_id: follower.id)
      end.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
  end

end
