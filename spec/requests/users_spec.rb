require 'rails_helper'

RSpec.describe 'users', :type => :request do
  let(:headers) {
    {
        "ACCEPT" => "application/json",
        "HTTP_ACCEPT" => "application/json"
    }
  }

  let(:user_params) {
    {
        'user' => {
            'email' => 'example@example.com',
            'password' => '123456',
            'password_confirmation' => '123456'
        }
    }
  }

  it 'sign up' do

    post '/api/v1/users', params: user_params, headers: headers

    expect(response.status).to eq(201)
    expect(response.content_type).to eq('application/json')
    expected_hash = {'id' => User.last.id.to_s, 'email' => user_params['user']['email']}
    expect(json).to eq(expected_hash)
  end

  it 'show nonexistent' do
    get '/api/v1/users/1', headers: headers
    expect(response.status).to eq(404)
    expect(response.content_type).to eq('application/json')
    expect(response.body).to eq({errors: ['Not found']}.to_json)
  end

  it 'show existent' do
    op = Api::V1::User::Create.(user_params)
    get "/api/v1/users/#{op.model.id}", headers: headers
    expect(response.status).to eq(200)
    expect(response.content_type).to eq('application/json')
    expected_hash = {'id' => User.last.id.to_s, 'email' => user_params['user']['email']}
    expect(json).to eq(expected_hash)
  end

end