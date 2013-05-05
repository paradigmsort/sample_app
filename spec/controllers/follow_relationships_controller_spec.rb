require 'spec_helper'

describe FollowRelationshipsController do

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before { sign_in user }

  describe "creating a relationship via Ajax" do

    it "should increment the relationship count" do
      expect { xhr :post, :create, follow_relationship: { followed_id: other_user.id } }.to change(FollowRelationship, :count).by(1)
    end

    it "should respond with success indicator" do
      xhr :post, :create, follow_relationship: { followed_id: other_user.id }
      response.should be_success
    end
  end

  describe "destroying a relationship via Ajax" do
    before { user.follow!(other_user) }
    let(:relationship) { user.follow_relationships.find_by_followed_id(other_user) }

    it "should decrement the relationship count" do
      expect { xhr :delete, :destroy, id: relationship.id }.to change(FollowRelationship, :count).by(-1)
    end

    it "should respond with success indicator" do
      xhr :delete, :destroy, id: relationship.id
      response.should be_success
    end
  end

end