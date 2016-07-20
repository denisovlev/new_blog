require 'rails_helper'

RSpec.describe Api::V1::User::Show do

  it 'shows' do
    op = create_user

    op2 = Api::V1::User::Show.({id: op.model.id.to_s})
    expect(op2.model).to eq(op.model)
  end

  it 'raises DocumentNotFound' do
    expect { Api::V1::User::Show.({id: 1}) }.to raise_error(Mongoid::Errors::DocumentNotFound)
  end

end

RSpec.describe Api::V1::User::Create do

  it 'creates' do
    op = create_user

    model = User.last
    expect(model.id).to eq(op.model.id)
    expect(model.email).to eq('user@example.com')
    expect(model.authentication_token).to_not be_empty
    expect(model.is_admin).to be_falsey
  end

  it 'unique validation' do
    create_user
    expect {create_user}.to raise_error(Trailblazer::Operation::InvalidContract)
  end

  describe Api::V1::User::Create::Admin do

    it 'creates' do
      op = create_user_admin

      model = User.last
      expect(model.id).to eq(op.model.id)
      expect(model.email).to eq('admin@example.com')
      expect(model.authentication_token).to_not be_empty
      expect(model.is_admin).to be_truthy
    end

  end

end

RSpec.describe Api::V1::User::SignIn do

  it 'signs in' do
    op = create_user
    res, op2 = Api::V1::User::SignIn.run({'user' => {'email' => 'user@example.com', 'password' => '123456'}})

    expect(res).to be_truthy
    output = JSON.parse(op2.to_json)
    expect(output['email']).to eq('user@example.com')
    expect(output['authentication_token']).to eq(op.model.authentication_token)
    expect(output['password']).to be_blank
  end

  it 'failed sign in' do
    op = create_user
    res, op2 = Api::V1::User::SignIn.run({'user' => {'email' => 'user@example.com', 'password' => '1234567'}})

    expect(res).to be_falsey
  end

  it 'failed sign no user' do
    op = create_user
    res, op2 = Api::V1::User::SignIn.run({'user' => {'email' => 'user123@example.com', 'password' => '1234567'}})

    expect(res).to be_falsey
  end

end
