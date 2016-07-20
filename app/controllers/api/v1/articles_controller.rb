class Api::V1::ArticlesController < Api::V1::BaseController

  def index
    render json: (present Api::V1::Article::Index, is_document: false), status: :ok
  end

  def show
    render json: Api::V1::Article::Show.(params), status: :ok
  end

  def create
    op = run Api::V1::Article::Create do |op|
      return render json: op, status: :created
    end
    api_error(status: :unprocessable_entity, errors: op.errors.messages)
  end

  def update
    op = run Api::V1::Article::Update do |op|
      return render json: op, status: :ok
    end
    api_error(status: :unprocessable_entity, errors: op.errors.messages)
  end

  def destroy
    op = run Api::V1::Article::Delete do
      return render status: :ok
    end
    api_error(status: :unprocessable_entity, errors: op.errors.messages)
  end

end
