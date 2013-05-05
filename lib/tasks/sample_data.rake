namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(name: "Example User",
                         email: "example@railstutorial.org",
                         password: "foobar",
                         password_confirmation: "foobar")
    admin.toggle!(:admin) #can't mass-assign since protected
    99.times do |n|
      name = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)

    end

    users_with_posts = User.all(limit: 6)
    50.times do
      content = Faker::Lorem.sentence(5)
      users_with_posts.each do |user|
        user.microposts.create!(content: content)
      end
    end

    user = User.all.first
    followers = User.all[2..50]
    followed_users = User.all[3..40]

    followers.each { |follower| follower.follow!(user) }
    followed_users.each { |followed_user| user.follow!(followed_user) }

  end
end