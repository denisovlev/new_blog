module Api::V1
  module Article
    module Representer

      class Show < Representable::Decorator
        include Representable::JSON

        property :id
        property :title
        property :body
      end

    end
  end
end