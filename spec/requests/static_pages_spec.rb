require 'spec_helper'

describe "StaticPages" do

  subject { page }

  shared_examples_for "all static pages" do 
    before { visit path }

    it { should have_selector('h1', :text => heading) }
    it "should have the right title" do 
      test_title(page_title)
    end

    it "should have correct header links" do
      test_link("sample app", "")
      test_link("Home", "")
      test_link("Help", "Help")
      test_link("Sign in", "Sign in")
    end

    it "should have correct footer links" do
      test_link("About", "About")
      test_link("Contact", "Contact")
    end
  end

  shared_examples_for "simple static pages" do
    let(:page_title) { heading.split.first }
    it_should_behave_like "all static pages"
  end

  describe "Home page" do
    let(:path) { root_path }
    let(:heading) { "Sample App" }
    let(:page_title) { "" }
    it_should_behave_like "all static pages"
    it "should have sign up link" do
      test_link("Sign up now!", "Sign up")
    end
  end

  describe "Help page" do
    let(:path) { help_path }
    let(:heading) { "Help" }
    it_should_behave_like "simple static pages"
  end

  describe "About page" do
    let(:path) { about_path }
    let(:heading) { "About Us" }
    it_should_behave_like "simple static pages"
  end

  describe "Contact page" do
    let(:path) { contact_path }
    let(:heading) { "Contact Us" }
    it_should_behave_like "simple static pages"
  end

end
