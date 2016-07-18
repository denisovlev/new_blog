class Api::V1::BaseController < ApplicationController
  before_action :destroy_session

  rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found!
  rescue_from Trailblazer::Operation::InvalidContract, with: :unprocessable_entity!

  def not_found!
    return api_error(status: 404, errors: 'Not found')
  end

  def unprocessable_entity!(e)
    return api_error(status: 404, errors: e.message)
  end

  def api_error(status: 500, errors: [])
    unless Rails.env.production?
      puts errors.full_messages if errors.respond_to? :full_messages
    end
    head status: status and return if errors.empty?

    render json: { errors: Array(errors) }.to_json, status: status
  end

  def destroy_session
    request.session_options[:skip] = true
  end
end