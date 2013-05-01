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

  it { should be_valid }

  its(:user_id) { should == user.id }
  its(:user) { should == user }

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
end
