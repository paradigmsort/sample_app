require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "Signin page" do
    before { visit signin_path }

    it { should have_selector('title'), text: "Sign in" }
    it { should have_selector('h1'), text: "Sign in" }

    describe "with invalid info" do
      describe "after sumission" do
        before { click_button "Sign in" }
        it { should have_selector('title'), text: "Sign in" }
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

        it { should have_selector('title'), text: user.name }
      end
    end
  end
end
