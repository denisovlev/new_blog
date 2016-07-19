class Api::V1::BaseController < ApplicationController
  before_action :destroy_session
  before_action :authenticate_user!
  before_action :add_user_to_params!

  attr_accessor :current_user

  rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found!
  rescue_from Trailblazer::NotAuthorizedError, with: :not_authorized!

  def not_found!
    api_error(status: :not_found, errors: 'Not found')
  end

  def not_authorized!
    api_error(status: :unauthorized, errors: 'Not found')
  end

  def api_error(status: 500, errors: [])
    unless Rails.env.production?
      puts errors.full_messages if errors.respond_to? :full_messages
    end
    head status: status and return if errors.empty?

    render json: format_errors(status, errors).to_json, status: status
  end

  def format_errors(status, errors)
    if status == :unprocessable_entity || status == 422
      return { errors: errors.map { |k,v| {k => v} } }
    end
    { errors: Array(errors) }
  end

  def destroy_session
    request.session_options[:skip] = true
  end

  def authenticate_user!
    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)

    user_email = options.blank?? nil : options[:email]
    user = user_email && ::User.where(email: user_email).first

    if user && ActiveSupport::SecurityUtils.secure_compare(user.authentication_token, token)
      @current_user = user
    else
      @current_user = nil
    end
  end

  def add_user_to_params!
    params[:current_user] = current_user
  end

end