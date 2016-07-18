require 'rails_helper'

RSpec.describe Api::V1::Article::Create do

  it 'creates article' do
    _, op = Api::V1::Article::Create.run({article: {title: 'first article', body: 'cool stuff about everything'}})
    expect(op.model.title).to eq('first article')
    expect(op.model.body).to eq('cool stuff about everything')
    expect(Article.order_by(created_at: -1).first.id).to eq(op.model.id)
  end

end
