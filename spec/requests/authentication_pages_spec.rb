require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_selector('title', text: "Sign in") }
    it { should have_selector('h1', text: "Sign in") }

    describe "with invalid info" do
      describe "after sumission" do
        before { click_button "Sign in" }
        it { should have_selector('title', text: "Sign in") }
        it { should have_selector('div.alert.alert-error', text: "Invalid ")}

        describe "error information should not persist" do
          before { click_link "Home" }
          it { should_not have_selector('div.alert.alert-error', text: "Invalid ")}
        end
      end
    end

    describe "with wrong password" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email", with: user.email
        fill_in "Password", with: "the wrong password"
      end
      describe "after submission" do
        before { click_button "Sign in" }

        it { should have_selector('title', text: "Sign in") }
        it { should have_selector('div.alert.alert-error', text: "Invalid ")}
      end
    end

    describe "with valid info" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email", with: user.email
        fill_in "Password", with: user.password
      end
      describe "after submission" do
        before { click_button "Sign in" }

        it { should have_selector('title', text: user.name) }
        it { should_not have_link('Sign in') }
        it { should have_link('Sign out', href: signout_path) }

        describe "persistance" do
          before { click_link "Home" }

          it { should_not have_link('Sign in') }
          it { should have_link('Sign out', href: signout_path) }
          it { should have_selector('h1', text: "Sample App") } # home page
        end

        describe "signing out" do
          before { click_link "Sign out" }

          it { should have_link('Sign in', href: signin_path) }
          it { should_not have_link('Sign out') }
          it { should have_selector('h1', text: "Sample App") } # home page
        end
      end
    end
  end
end
