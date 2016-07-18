require 'rails_helper'

def create_user
  Api::V1::User::Create.({'user' => {'email' => 'user@example.com', 'password' => '123456', 'password_confirmation' => '123456'}})
end

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
  end

end

RSpec.describe Api::V1::User::Update do

  it 'updates' do
    op = create_user
    Api::V1::User::Update.({
        id: op.model.id,
        'user' => {'email' => 'hacked@mail', 'password' => '999999', 'password_confirmation' => '999999'}
    })

    expect(User.last.email).to eq('hacked@mail')
  end

end
