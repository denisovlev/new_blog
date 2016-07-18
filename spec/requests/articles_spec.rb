require 'rails_helper'

RSpec.describe 'articles', :type => :request do
  let(:headers) {
    {
        "ACCEPT" => "application/json",     # This is what Rails 4 accepts
        "HTTP_ACCEPT" => "application/json" # This is what Rails 3 accepts
    }
  }

  let(:article_params) {
    {article: {
        title: 'some great things',
        body: 'some text body'
    }}
  }

  it 'get existing' do
    _, op = Api::V1::Article::Create.run(article_params)
    get "/api/v1/articles/#{op.model.id}", headers: headers
    expect(response.status).to eq(200)
    expect(response.content_type).to eq('application/json')
    expect(response.body).to eq(({id: Article.last.id}.merge(article_params[:article])).to_json)
  end

  it 'post' do
    post "/api/v1/articles", params: article_params, headers: headers
    expect(response.status).to eq(201)
    expect(response.content_type).to eq('application/json')
    expect(response.body).to eq(({id: Article.last.id}.merge(article_params[:article])).to_json)
  end

end