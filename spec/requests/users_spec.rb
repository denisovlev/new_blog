require 'rails_helper'

RSpec.describe 'users', :type => :request do
  let(:headers) {
    {
        "ACCEPT" => "application/json",     # This is what Rails 4 accepts
        "HTTP_ACCEPT" => "application/json" # This is what Rails 3 accepts
    }
  }

  let(:user_params) {
    {
        user: {
            email: 'example@example.com',
            password: '123456',
            password_confirmation: '123456'
        }
    }
  }

  it 'sign up' do

    post '/api/v1/users', params: user_params, headers: headers

    expect(response.status).to eq(201)
    expect(response.content_type).to eq('application/json')
    expect(response.body).to eq({}.to_json)
  end

  it 'show nonexistent' do
    get '/api/v1/users/1', headers: headers
    expect(response.status).to eq(404)
    expect(response.content_type).to eq('application/json')
    expect(response.body).to eq({errors: ['Not found']}.to_json)
  end

  it 'show existent' do
    res, op = Api::V1::User::Create.run(user_params)
    get "/api/v1/users/#{op.model.id}", headers: headers
    expect(response.status).to eq(200)
    expect(response.content_type).to eq('application/json')
    expect(response.body).to eq({id: User.last.id, email: 'example@example.com'}.to_json)
  end

end