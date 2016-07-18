module Api::V1
  class UsersController < BaseController
    def show
      render json: Api::V1::User::Show.(params), status: :ok
    end

    def create
      render json: Api::V1::User::Create.(params), status: :created
    end

  end
end