module Api::V1
  module User
    module Representer

      class Show < Representable::Decorator
        include Representable::JSON

        property :id
        property :email
      end

    end
  end
end