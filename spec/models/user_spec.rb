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
end
