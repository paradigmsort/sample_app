require 'spec_helper'

describe "UserPages" do

  subject { page }

  describe "Signup page" do
    before { visit signup_path }

    it { should have_selector('h1', text: "Sign up") }
    it { should have_selector('title', text: full_title("Sign up")) }

    describe "with empty form" do
      it "should not create a user" do
        expect { click_button "Create my account" }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button "Create my account" }

        it { should have_selector('title'), text:full_title("Sign up") }
        it { should have_content('error') }
        it { should_not have_content('digest') }
      end
    end

    describe "valid signup" do
      before do
        fill_in "Name", with: "Example User"
        fill_in "Email", with: "example@user.com"
        fill_in "Password", with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button "Create my account" }.to change(User, :count).by(1)
      end
    end
  end

  describe "User page" do
    let(:user) { FactoryGirl.create(:user) }
    before {  visit user_path(user) }

    it { should have_selector('h1', text: user.name) }
    it { should have_selector('title', text: user.name) }
  end
end
