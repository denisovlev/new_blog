require 'rails_helper'

RSpec.describe 'articles', :type => :request do
  let(:headers) {
    {
        "ACCEPT" => "application/json",     # This is what Rails 4 accepts
        "HTTP_ACCEPT" => "application/json" # This is what Rails 3 accepts
    }
  }

  let(:article_params) {
    {'article' => {
        'title' => 'some great things',
        'body' => 'some text body'
    }}
  }

  it 'get existing' do
    op = Api::V1::Article::Create.(article_params)
    get "/api/v1/articles/#{op.model.id}", headers: headers
    expect(response.status).to eq(200)
    expect(response.content_type).to eq('application/json')
    expected_hash = article_params['article'].merge('id' => Article.last.id.to_s)
    expect(json).to eq(expected_hash)
  end

  it 'create' do
    post "/api/v1/articles", params: article_params, headers: headers
    expect(response.status).to eq(201)
    expect(response.content_type).to eq('application/json')
    expected_hash = article_params['article'].merge('id' => Article.last.id.to_s)
    expect(json).to eq(expected_hash)
  end

  it 'create with invalid' do
    article_params['article']['title'] = nil
    article_params['article']['body'] = 'a' * 1001
    post "/api/v1/articles", params: article_params, headers: headers
    expect(response.status).to eq(422)
    expect(response.content_type).to eq('application/json')
    expected_hash = {
        "errors"=>[
            {"title"=>["can't be blank", "is too short (minimum is 10 characters)"]},
            {"body"=>["is too long (maximum is 1000 characters)"]}
        ]
    }
    expect(json).to eq(expected_hash)
  end

  it 'update' do
    op = Api::V1::Article::Create.(article_params)
    article_params['article']['title'] = 'Updated title'
    put "/api/v1/articles/#{op.model.id}", params: article_params, headers: headers
    expect(response.status).to eq(200)
    expect(response.content_type).to eq('application/json')
    expected_hash = article_params['article'].merge('id' => Article.last.id.to_s, 'title' => 'Updated title')
    expect(json).to eq(expected_hash)
  end

  it 'update with invalid' do
    op = Api::V1::Article::Create.(article_params)
    article_params['article']['title'] = ''
    article_params['article']['body'] = ''
    put "/api/v1/articles/#{op.model.id}", params: article_params, headers: headers
    expect(response.status).to eq(422)
    expect(response.content_type).to eq('application/json')
    expected_hash = {
        "errors"=>[
            {"title"=>["can't be blank", "is too short (minimum is 10 characters)"]},
            {"body"=>["can't be blank"]}
        ]
    }
    expect(json).to eq(expected_hash)
  end

  it 'delete' do
    op = Api::V1::Article::Create.(article_params)

    delete "/api/v1/articles/#{op.model.id}", params: article_params, headers: headers
    expect(response.status).to eq(200)
    expect {User.find(op.model.id)}.to raise_error(Mongoid::Errors::DocumentNotFound)
  end

end