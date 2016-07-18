class Api::V1::BaseController < ApplicationController
  before_action :destroy_session

  rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found!

  def not_found!
    api_error(status: 404, errors: 'Not found')
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
end