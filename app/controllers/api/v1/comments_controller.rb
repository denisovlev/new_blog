module Api::V1
  class CommentsController < BaseController
    def index
      render json: (present Api::V1::Comment::Index, is_document: false), status: :ok
    end

    def show
      render json: Api::V1::Comment::Show.(params), status: :ok
    end

    def create
      op = run Api::V1::Comment::Create do |op|
        return render json: op, status: :created
      end
      api_error(status: :unprocessable_entity, errors: op.errors.messages)
    end

    def update
      op = run Api::V1::Comment::Update do |op|
        return render json: op, status: :ok
      end
      api_error(status: :unprocessable_entity, errors: op.errors.messages)
    end

    def destroy
      op = run Api::V1::Comment::Delete do
        return render status: :ok
      end
      api_error(status: :unprocessable_entity, errors: op.errors.messages)
    end
  end
end