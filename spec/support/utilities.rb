def full_title(page_title)
  base_title = "Ruby on Rails Tutorial Sample App"
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

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
