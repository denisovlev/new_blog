require 'rails_helper'

RSpec.describe 'users', :type => :request do

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

    post '/api/v1/users', user_params

    expect(last_response.status).to eq(201)
    expected_hash = {'id' => User.last.id.to_s, 'email' => user_params['user']['email']}
    expect(json).to eq(expected_hash)
  end

  it 'sign up failed' do
    Api::V1::User::Create.(user_params)
    post '/api/v1/users', user_params

    expect(last_response.status).to eq(422)
    expected_hash = {"errors"=>[{"email"=>["Email is already taken"]}]}
    expect(json).to eq(expected_hash)
  end

  it 'sign in' do
    op = Api::V1::User::Create.(user_params)
    post '/api/v1/users/sign_in', {'user' => {email: 'example@example.com', 'password' => '123456'}}

    expect(last_response.status).to eq(201)
    user = op.model
    expected_hash = {'id' => user.id.to_s, 'email' => user.email, 'authentication_token' => user.authentication_token}
    expect(json).to eq(expected_hash)
  end

  it 'sign in failed' do
    Api::V1::User::Create.(user_params)
    post '/api/v1/users/sign_in', {'user' => {email: 'example@example.com', 'password' => '1234567'}}

    expect(last_response.status).to eq(422)
    expected_hash = {"errors"=>[{"password"=>["Invalid password"]}]}
    expect(json).to eq(expected_hash)
  end

  it 'show nonexistent' do
    sign_in(Api::V1::User::Create.(user_params).model)
    get '/api/v1/users/1'
    expect(last_response.status).to eq(404)
    expect(last_response.body).to eq({errors: ['Not found']}.to_json)
  end

  it 'show existent' do
    op = Api::V1::User::Create.(user_params)
    get "/api/v1/users/#{op.model.id}"
    expect(last_response.status).to eq(200)
    expected_hash = {'id' => User.last.id.to_s, 'email' => user_params['user']['email']}
    expect(json).to eq(expected_hash)
  end

end