include ApplicationHelper

def test_title(title)
  page.should have_selector 'title', text: full_title(title)
  if title.empty?
    page.should_not have_selector 'title', text: "|"
  end
end

def test_link(link_name,target_title)
  visit path # return to the page under test
  click_link link_name
  # check we were linked to a page with the given title
  test_title(target_title)
end

def sign_in(user)
  visit signin_path
  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end

RSpec::Matchers.define :have_title do |title|
  match do |page|
    if title.empty?
      page.should have_selector('title', text: full_title(title)) && have_no_selector('title', text: "|")
    else
      page.should have_selector('title', text: full_title(title))
    end
  end

  failure_message_for_should do |page|
    "should have title #{full_title(title)} but instead has #{page.html}"
  end
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end
