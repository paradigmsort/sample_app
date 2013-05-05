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

require 'spec_helper'

describe User do
  before { @user = User.new(name: "Example User", email: "user@example.com", password: "secret", password_confirmation: "secret") }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:follow_relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_follow_relationships) }
  it { should respond_to(:followers) }

  it { should be_valid }

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  let(:max_name_length) { 50 }
  describe "when name is too long" do
    before { @user.name = "a"*(max_name_length + 1) }
    it { should_not be_valid }
  end

  describe "when name is max length" do
    before { @user.name = "a"*max_name_length }
    it { should be_valid }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when email is not in valid format" do
    it "should not be valid" do
      addresses = ["user@foo,com",
                   "user_at_foo.org",
                   "example_user@foo.",
                   "foo@bar_baz.com",
                   "foo @ bar.com",
                   "foo@bar+bax.com",
                  ]
      addresses.each do | invalid_address |
        @user.email = invalid_address
        @user.should_not be_valid
      end
    end
  end

  describe "when email is in valid format" do
    it "should be valid" do
      addresses = ["user@foo.COM",
                   "A_US-ER@f.b.org",
                   "frst.lst@foo.jp",
                   "a+b@baz.cn"
                  ]
      addresses.each do | valid_address |
        @user.email = valid_address
        @user.should be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when email with alternate capitalization is already taken" do
    before do
      user_with_upcase_email = @user.dup
      user_with_upcase_email.email = @user.email.upcase
      user_with_upcase_email.save
    end

    it { should_not be_valid }
  end

  describe "when email address has non-lower case" do
    let(:nlc_email) { "Foo@examPLE.cOm" }

    it "should be saved as lower case" do
      @user.email = nlc_email
      @user.save
      @user.reload.email.should == nlc_email.downcase
    end
  end

  describe "when password is not present" do
    before { @user.password =  @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when passwords do not match" do
    before { @user.password = @user.password_confirmation + 'a' }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "when password is too short" do
    before { @user.password = @user.password_confirmation = 'a'*5 }
    it { should_not be_valid }
  end

  describe "when user is admin" do
    before do
     @user.save! # default is non-admin
     @user.toggle!(:admin)
   end

    it { should be_admin }
  end

  describe "admin attribute" do
    it "is not accessible" do
      expect do
       @user.update_attributes(admin: true)
     end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
   end
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }
      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  describe "remember_token creation" do
    before { @user.save }

    its(:remember_token) { should_not be_blank }
    it "should have new remember_token on each save" do
      expect { @user.save }.to change(@user, :remember_token)
    end
  end

  describe "associated microposts" do
    before { @user.save }
    let!(:first_post) { FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago) }
    let!(:second_post) { FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago) }

    describe "retrieval order" do
      specify { @user.microposts.first.should == second_post }
      specify { @user.microposts.second.should == first_post }
    end

    it "should be destroyed along with user"  do
      microposts = @user.microposts.dup
      @user.destroy

      microposts.should_not be_empty
      microposts.each do | post |
        Micropost.find_by_id(post.id).should be_nil
      end
    end
  end

  describe "feed" do
    before { @user.save }
    let!(:user_post) { FactoryGirl.create(:micropost, user: @user) }
    let!(:unfollowed_post) { FactoryGirl.create(:micropost, user: FactoryGirl.create(:user)) } 

    describe "contents" do
      specify { @user.feed.should include(user_post) }
      specify { @user.feed.should_not include(unfollowed_post) }
    end
  end

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end

    it {should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    it "followed user should give a follower" do
      other_user.followers.should include(@user)
    end

    it "should cease when other user is destroyed" do
      reverse_relationships = other_user.reverse_follow_relationships.dup
      other_user.destroy

      @user.followed_users.should be_empty
      @user.follow_relationships.should be_empty
      reverse_relationships.should_not be_empty
      reverse_relationships.each do |relationship|
        FollowRelationship.find_by_id(relationship.id).should be_nil
      end
    end

    it "should cease when user is destroyed" do
      relationships = @user.follow_relationships.dup
      @user.destroy

      other_user.followed_users.should be_empty
      other_user.reverse_follow_relationships.should be_empty
      relationships.should_not be_empty
      relationships.each do |relationship|
        FollowRelationship.find_by_id(relationship.id).should be_nil
      end
    end

    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end
  end
end
