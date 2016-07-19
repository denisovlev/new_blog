module Requests
  module JsonHelpers
    def json
      JSON.parse(last_response.body)
    end
  end

  module Authentication
    def sign_in(user)
      header('Authorization', "Token token=\"#{user.authentication_token}\", email=\"#{user.email}\"")
    end
  end
end