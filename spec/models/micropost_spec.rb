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

require 'spec_helper'

describe Micropost do
  let(:user) { FactoryGirl.create(:user) }
  let(:micropost) { FactoryGirl.create(:micropost, user: user) }

  subject { micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:in_reply_to) }

  it { should be_valid }

  its(:user_id) { should == user.id }
  its(:user) { should == user }
  its(:in_reply_to) { should be_nil }

  describe "when user id is missing" do
    before { micropost.user_id = nil}

    it { should_not be_valid }
  end

  describe "when content is empty" do
    before { micropost.content = " " }

    it { should_not be_valid }
  end

  describe "user_id attribute" do
    it "is not accessible" do
      expect do
        micropost.update_attributes(user_id: nil)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "content length" do
    describe "too long" do
      before { micropost.content = "a" * 141 }

      it { should_not be_valid }
    end
    describe "max length" do
      before { micropost.content = "a" * 140 }

      it { should be_valid }
    end
  end

  describe "no in_reply_to" do
    before { micropost.save }

    its(:in_reply_to) { should be_nil }
  end

  describe "in_reply_to" do
      let(:target_user) { FactoryGirl.create(:user) }
    before do
      micropost.content = "@" + target_user.id.to_s + " " + micropost.content
      micropost.save
    end

    it { should be_valid }
    its(:in_reply_to) { should == target_user.id }
  end
end
