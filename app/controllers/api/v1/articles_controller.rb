class Api::V1::ArticlesController < ApplicationController

  def create
    render json: Api::V1::Article::Create.(params), status: :created
  end

  def show
    render json: Api::V1::Article::Show.(params), status: :ok
  end

end
