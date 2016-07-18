class User
  include Mongoid::Document

  field :email, type: String
  field :auth_meta_data, type: Hash
end