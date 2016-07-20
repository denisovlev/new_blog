class User
  include Mongoid::Document

  field :email, type: String
  field :auth_meta_data, type: Hash
  field :authentication_token, type: String
  field :is_admin, type: Boolean, default: false

  has_many :articles
  has_many :comments
end