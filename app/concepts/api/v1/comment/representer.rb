module Api::V1
  module Comment
    module Representer

      class Show < Representable::Decorator
        include Representable::JSON

        property :id
        property :user_id
        property :article_id
        property :body
      end

    end
  end
end