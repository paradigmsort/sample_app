require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_title("Sign in") }
    it { should have_main_heading("Sign in") }

    describe "with invalid info" do
      describe "after sumission" do
        before { click_button "Sign in" }
        it { should have_title("Sign in") }
        it { should have_error_message("Invalid ") }

        describe "error information should not persist" do
          before { click_link "Home" }
          it { should_not have_error_message("Invalid ") }
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

        it { should have_title("Sign in") }
        it { should have_error_message("Invalid ") }
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

        it { should have_title(user.name) }
        it { should_not have_link('Sign in') }
        it { should have_link('Users', href: users_path) }
        it { should have_link('Profile', href: user_path(user)) }
        it { should have_link('Settings', href: edit_user_path(user)) }
        it { should have_link('Sign out', href: signout_path) }

        describe "persistance" do
          before { click_link "Home" }

          it { should_not have_link('Sign in') }
          it { should have_link('Sign out', href: signout_path) }
          it { should have_title('') } # home page
        end

        describe "signing out" do
          before { click_link "Sign out" }

          it { should have_link('Sign in', href: signin_path) }
          it { should_not have_link('Users') }
          it { should_not have_link('Profile') }
          it { should_not have_link('Settings') }
          it { should_not have_link('Sign out') }
          it { should have_title('') } # home page
        end
      end
    end

    describe "as non admin user" do
      describe "submitting the delete action" do
        let(:non_admin_user) { FactoryGirl.create(:user) }
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.save
          sign_in non_admin_user
        end

        it "should not delete the user" do
          expect { delete user_path(other_user) }.not_to change(User, :count)
        end
      end
    end

    describe "as admin user" do
      let(:admin_user) { FactoryGirl.create(:admin) }
      before { sign_in admin_user }

      it "should not be able to delete yourself" do
        expect { delete user_path(admin_user) }.not_to change(User, :count)
      end
    end
  end
end
