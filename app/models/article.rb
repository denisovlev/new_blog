class Article
  include Mongoid::Document

  field :title, type: String
  field :body, type: String

  belongs_to :user
end
