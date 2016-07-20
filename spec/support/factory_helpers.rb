def create_user(user_params = {})
  Api::V1::User::Create.({
      'user' => {
          'email' => 'user@example.com', 'password' => '123456', 'password_confirmation' => '123456'
      }.merge(user_params)
  })
end

def create_user_admin(user_params = {})
  Api::V1::User::Create::Admin.({
      'user' => {
          'email' => 'admin@example.com', 'password' => '123456', 'password_confirmation' => '123456'
      }.merge(user_params)
  })
end

def create_article(user = nil, article_params = {})
  user = create_user.model if user.nil?
  Api::V1::Article::Create.({
      current_user: user,
      'article' => {
          'title' => 'first article', 'body' => 'cool stuff about everything'
      }.merge(article_params)
  })
end

def create_comment(user = nil, article = nil, params = {})
  user = create_user.model if user.nil?
  article = create_article(user).model if article.nil?
  Api::V1::Comment::Create.({
      current_user: user,
      article_id: article.id.to_s,
      'comment' => {
          'body' => 'First comment'
      }.merge(params)
  })
end