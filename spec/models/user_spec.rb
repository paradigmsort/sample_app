# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do
  before { @user = User.new(name: "Example User", email: "user@example.com") }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }

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
end