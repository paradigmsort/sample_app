require 'spec_helper'

describe "MicropostPages" do
  subject { page }

  describe "Home page" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit root_path
    end

    it { should have_title("") }
    it { should have_content(user.name) }
    it { should have_link("View my profile", href: user_path(user)) }
    it { should have_content(user.microposts.count) }
    it { should have_button("Post") }

    describe "pluralization" do

      describe "one post" do
        before do
          FactoryGirl.create(:micropost, user: user)
          visit root_path
        end

        it { should have_content("micropost") }
        it { should_not have_content("microposts") }
      end

      describe "two posts" do
        before do
          2.times { FactoryGirl.create(:micropost, user: user) }
          visit root_path
        end

        it { should have_content("microposts") }
      end
    end

    describe "micropost creation" do

      describe "with invalid information" do

        it "should not create a post" do
          expect { click_button "Post" }.not_to change(Micropost, :count)
        end

        describe "error message" do
          before { click_button "Post" }

          it { should have_content "error" }
        end
      end

      describe "with valid information" do
        before { fill_in 'micropost_content', with: "Lorem ipsum" }

        it "should create a new post" do
          expect { click_button "Post"}.to change(Micropost, :count).by(1)
        end

        describe "success message" do
          before { click_button "Post" }

          it { should have_selector('div.alert.alert-success') }

          describe "should disappear on reload" do
            before { visit root_path }

            it { should_not have_selector('div.alert-success') }
          end
        end
      end
    end

    describe "feed" do
      before do
        2.times { FactoryGirl.create(:micropost, user: user) }
        visit root_path
      end

      it "should show the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end
    end
  end
end
