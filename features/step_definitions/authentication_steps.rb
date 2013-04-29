Given /^a user visits the signin page$/ do
  visit signin_path
end

Given /^the user has an account$/ do
  @user = User.create(name: "Example User", email:"example@user.com", 
    password: "secret", password_confirmation: "secret")
end

When /^he submits invalid signin information$/ do
  click_button "Sign in"
end

When /^the user submits valid signin information$/ do
  fill_in "Email", with: @user.email
  fill_in "Password", with: @user.password
  click_button "Sign in"
end

Then /^he should see an error message$/ do
  page.should have_selector('div.alert.alert-error')
end

Then /^he should see his profile page$/ do
  page.should have_selector('title', text: @user.name)
end

Then /^he should see a signout link$/ do
  page.should have_link("Sign out")
end