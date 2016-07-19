module Api::V1
  class UsersController < BaseController
    def show
      render json: Api::V1::User::Show.(params), status: :ok
    end

    def create
      op = run Api::V1::User::Create do |op|
        return render json: op, status: :created
      end
      api_error(status: :unprocessable_entity, errors: op.errors.messages)
    end

    def sign_in
      op = run Api::V1::User::SignIn do |op|
        return render json: op, status: :created
      end
      api_error(status: :unprocessable_entity, errors: op.errors.messages)
    end

  end
end