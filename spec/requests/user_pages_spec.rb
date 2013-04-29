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

    describe "with valid form contents" do
      before do
        fill_in "Name", with: "Example User"
        fill_in "Email", with: "example@user.com"
        fill_in "Password", with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button "Create my account" }.to change(User, :count).by(1)
      end

      describe "after submission" do
        before { click_button "Create my account" }

        it { should have_selector('title', text:full_title("Example User")) }
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

    it { should have_selector('h1', text: "Update your profile") }
    it { should have_selector('title', text: "Edit user") }
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
        fill_in "Confirmation", with: user.password
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

    it { should have_selector('title', text: "Edit user") }
  end

  describe "User index page" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      FactoryGirl.create(:user, name: "Joe", email: "joe@example.com")
      FactoryGirl.create(:user, name: "Harry", email: "harry@example.com")
      sign_in user
      visit users_path
    end

    it { should have_selector("title", text:"All Users")}
    it { should have_selector("h1", text:"All Users")}
    it "should list each user" do
      User.all.each do |user|
        page.should have_selector('li', text: user.name)
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
