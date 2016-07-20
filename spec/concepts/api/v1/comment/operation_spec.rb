require 'rails_helper'

RSpec.describe Api::V1::Comment::Show do

  it 'shows' do
    op = create_comment

    model = Comment.last
    expect(model).to eq(op.model)
  end

end

RSpec.describe Api::V1::Comment::Create do

  it 'creates' do
    user = create_user.model
    article = create_article(user).model
    op = create_comment(user, article)

    model = Comment.last
    expect(model.body).to eq('First comment')
    expect(model.persisted?).to be_truthy
    expect(model.id).to eq(op.model.id)
    expect(model.user).to eq(user)
    expect(model.article).to eq(article)
  end

end

RSpec.describe Api::V1::Comment::Update do

  it 'updates' do
    user = create_user.model
    user2 = create_user_admin.model
    article1 = create_article(user).model
    op = create_comment(user, article1)
    article2 = create_article(user).model
    op2 = Api::V1::Comment::Update.({
        id: op.model.id.to_s,
        current_user: user2,
        article_id: article2.id.to_s,
        'comment' => {'body' => 'super cool stuff about everything'}
    })

    model = Comment.last
    expect(model.body).to eq('super cool stuff about everything')
    expect(model.persisted?).to be_truthy
    expect(model.id).to eq(op2.model.id)
    expect(model.user).to eq(user)
    expect(model.article).to eq(article1)
  end

end

RSpec.describe Api::V1::Comment::Delete do

  it 'destroys' do
    user = create_user.model
    op = create_comment(user)
    op2 = Api::V1::Comment::Delete.({id: op.model.id.to_s, current_user: user})

    expect(op2.model.destroyed?).to be_truthy
    expect {Comment.find(op.model.id.to_s)}.to raise_error(Mongoid::Errors::DocumentNotFound)
  end

end