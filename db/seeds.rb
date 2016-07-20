# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin = Api::V1::User::Create::Admin.({
    'user' => {
        'email' => 'admin@example.com', 'password' => '123456', 'password_confirmation' => '123456'
    }
}).model

article = Api::V1::Article::Create.({
    current_user: admin,
    'article' => {
        'title' => 'Welcome to our blog!', 'body' => 'It has been so long. Enjoy!'
    }
}).model

Api::V1::Comment::Create.({
    current_user: admin,
    article_id: article.id.to_s,
    'comment' => {
        'body' => 'You can comment on stuff. Did you know that?'
    }
})