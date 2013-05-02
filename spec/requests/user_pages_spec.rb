require 'spec_helper'

describe "UserPages" do

  subject { page }

  describe "Signup page" do
    before { visit signup_path }

    it { should have_main_heading("Sign up") }
    it { should have_title("Sign up") }

    describe "with empty form" do
      it "should not create a user" do
        expect { click_button "Create my account" }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button "Create my account" }

        it { should have_title("Sign up") }
        it { should have_content('error') }
        it { should_not have_content('digest') }
      end
    end

    describe "with valid form contents" do
      before do
        fill_in "Name", with: "Example User"
        fill_in "Email", with: "example@user.com"
        fill_in "Password", with: "foobar"
        fill_in "Confirm Password", with: "foobar"
      end

      it "should create a user" do
        expect { click_button "Create my account" }.to change(User, :count).by(1)
      end

      describe "after submission" do
        before { click_button "Create my account" }

        it { should have_title("Example User") }
        it { should have_content('Welcome') }
        it { should have_link('Sign out') }
      end
    end
  end

  describe "Edit page" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    it { should have_main_heading("Update your profile") }
    it { should have_title("Edit user") }
    it { should have_link("change", href:"http://gravatar.com/emails") }

    describe "with invalid information" do 
      before { click_button "Save changes" }

      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name) { "New Name" }
      let(:new_email) { "new@email.com" }
      before do
        fill_in "Name", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { should have_selector("title", text:new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should == new_name }
      specify { user.reload.email.should == new_email }
    end
  end

  describe "non signed-in users" do
    let(:user) { FactoryGirl.create(:user) }

    describe "visiting the edit page" do
      before { visit edit_user_path(user) }

      it { should have_selector("title", text: "Sign in") }
      it { should have_selector('div.alert.alert-notice') }
    end

    describe "visiting the user index" do
      before { visit users_path }

      it { should have_selector("title", text: "Sign in") }
      it { should have_selector('div.alert.alert-notice') }
    end

    describe "submitting to the update action" do
      before { put user_path(user) }
      specify { response.should redirect_to(signin_path) }
    end

    describe "trying to create a micropost" do
      before { post microposts_path }
      specify { response.should redirect_to(signin_path) }
    end

    describe "trying to destroy a micropost" do
      before { delete micropost_path(FactoryGirl.create(:micropost)) }
      specify { response.should redirect_to(signin_path) }
    end
  end

  describe "as wrong user" do
    let(:user) { FactoryGirl.create(:user) }
    let(:wrong_user) { FactoryGirl.create(:user, email:"wrong@user.com") }
    before { sign_in user }

    describe "visiting the edit page" do
      before { visit edit_user_path(wrong_user) }
      it { should_not have_selector("title", text: "Edit user") }
    end

    describe "submitting to the update action" do
      before { put user_path(wrong_user) }
      specify { response.should redirect_to(root_path) }
    end
  end

  describe "friendly forwarding" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      visit edit_user_path(user) #redirected to sign in page
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Sign in"
    end

    it { should have_title("Edit user") }
  end

  describe "User index page" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_selector("title", text:"All Users")}
    it { should have_selector("h1", text:"All Users")}

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user from page 1" do
        User.paginate(page: 1).should_not be_empty
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end

      it "should not list other users" do
        User.paginate(page: 2).should_not be_empty
        User.paginate(page: 2).each do |user|
          page.should_not have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do
      describe "for administrators" do
        let(:admin) { FactoryGirl.create(:admin) }
        before(:each) do
          sign_in admin
          visit users_path
        end
        it { should have_link('delete', href: user_path(user)) }
        it { should_not have_link('delete', href: user_path(admin)) }

        it "should delete the user" do
          expect { click_link 'delete' }.to change(User, :count).by(-1)
        end
      end

      describe "for non-administrators" do
        it { should_not have_link("delete") }
      end
    end

  end

  describe "User page" do
    let(:user) { FactoryGirl.create(:user) }
    before {  visit user_path(user) }

    it { should have_main_heading(user.name) }
    it { should have_title(user.name) }

    describe "no microposts" do
      it { should_not have_selector('div.pagination') }
    end

    describe "microposts" do
      let!(:m1) { FactoryGirl.create(:micropost, user: user, created_at: 1.day.ago) }
      let!(:m2) { FactoryGirl.create(:micropost, user: user) }
      before {  visit user_path(user) }

      it { should have_content(m1.content) }
      it { should have_content("Posted 1 day ago.")}
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }

      describe "other users" do
        let!(:other_user) { FactoryGirl.create(:user) }
        let!(:m3) { FactoryGirl.create(:micropost, user: other_user) }
        before { visit user_path(user) }

        it { should_not have_content(m3.content) }
      end

      describe "pagination" do
        before(:all) { 100.times { FactoryGirl.create(:micropost, user: user) } }

        it { should have_selector('div.pagination') }

        it "should list each micropost from page 1" do
          user.microposts.paginate(page: 1).should_not be_empty
          user.microposts.paginate(page: 1).each do |post|
            page.should have_selector('li', text: post.content)
          end
        end

        it "should not list other users" do
          user.microposts.paginate(page: 2).should_not be_empty
          user.microposts.paginate(page: 2).each do |post|
            page.should_not have_selector('li', text: post.content)
          end
        end
      end
    end
  end
end
