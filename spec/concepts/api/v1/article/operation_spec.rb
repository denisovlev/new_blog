require 'rails_helper'

def create_article
  Api::V1::Article::Create.({'article' => {'title' => 'first article', 'body' => 'cool stuff about everything'}})
end

RSpec.describe Api::V1::Article::Show do

  it 'shows article' do
    op = create_article

    op2 = Api::V1::Article::Show.({id: op.model.id.to_s})
    expect(op2.model).to eq(op.model)
  end

  it 'raises DocumentNotFound' do
    expect { Api::V1::Article::Show.({id: 1}) }.to raise_error(Mongoid::Errors::DocumentNotFound)
  end

end

RSpec.describe Api::V1::Article::Create do

  it 'creates article' do
    op = create_article

    model = Article.last
    expect(model.title).to eq('first article')
    expect(model.body).to eq('cool stuff about everything')
    expect(model.persisted?).to be_truthy
    expect(model.id).to eq(op.model.id)
  end

end

RSpec.describe Api::V1::Article::Update do

  it 'updates article' do
    op = create_article
    op2 = Api::V1::Article::Update.({
        id: op.model.id.to_s,
        'article' => {'title' => 'second article', 'body' => 'super cool stuff about everything'}
    })

    model = Article.last
    expect(model.title).to eq('second article')
    expect(model.body).to eq('super cool stuff about everything')
    expect(model.persisted?).to be_truthy
    expect(model.id).to eq(op2.model.id)
  end

end

RSpec.describe Api::V1::Article::Delete do

  it 'destroys article' do
    op = create_article
    op2 = Api::V1::Article::Delete.({id: op.model.id.to_s})

    expect(op2.model.destroyed?).to be_truthy
    expect {Article.find(op.model.id.to_s)}.to raise_error(Mongoid::Errors::DocumentNotFound)
  end

end