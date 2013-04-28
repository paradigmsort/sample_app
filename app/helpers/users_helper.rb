module UsersHelper
  def gravatar_for(user)
    digest = Digest::MD5::hexdigest(user.email.downcase)
    uri = "https://secure.gravatar.com/avatar/#{digest}"
    image_tag(uri, alt: user.name, class: "gravatar" )
  end
end
