require 'rails_helper'

RSpec.describe 'articles', :type => :request do

  let(:article_params) {
    {'article' => {
        'title' => 'some great things',
        'body' => 'some text body'
    }}
  }

  describe 'unauthenticated guest' do
    before(:each) do
      @user = create_user.model
    end

    it 'index' do
      1.upto(10) do |i|
        create_article(@user, article_params['article'])
      end
      get "/api/v1/articles"
      expect(last_response.status).to eq(200)
      expected_hash = {}
      expected_hash['articles'] = Article.all.map do |a|
        article_params['article'].merge({ 'id' => a.id.to_s })
      end
      expect(json).to eq(expected_hash)
    end

    it 'get existing' do
      op = create_article(@user, article_params['article'])
      get "/api/v1/articles/#{op.model.id}"
      expect(last_response.status).to eq(200)
      expected_hash = article_params['article'].merge('id' => Article.last.id.to_s)
      expect(json).to eq(expected_hash)
    end

    it 'create' do
      post "/api/v1/articles", article_params
      expect(last_response.status).to eq(401)
      expect(Article.last).to be_nil
    end

    it 'update' do
      op = create_article(@user, article_params['article'])
      article_params['article']['title'] = 'Updated title'
      put "/api/v1/articles/#{op.model.id}", article_params
      expect(last_response.status).to eq(401)
      expect(Article.last).to_not eq('Updated title')
    end

    it 'delete' do
      op = create_article(@user, article_params['article'])

      delete "/api/v1/articles/#{op.model.id}", article_params
      expect(last_response.status).to eq(401)
      expect(Article.find(op.model.id)).to eq(op.model)
    end
  end

  describe 'authenticated user not creator' do
    before(:each) do
      @user = create_user.model
      @user2 = create_user(email: 'another_user@example.com').model
      sign_in(@user2)
    end

    it 'index' do
      1.upto(10) do |i|
        create_article(@user, article_params['article'])
      end
      get "/api/v1/articles"
      expect(last_response.status).to eq(200)
      expected_hash = {}
      expected_hash['articles'] = Article.all.map do |a|
        article_params['article'].merge({ 'id' => a.id.to_s })
      end
      expect(json).to eq(expected_hash)
    end

    it 'get existing' do
      op = create_article(@user, article_params['article'])
      get "/api/v1/articles/#{op.model.id}"
      expect(last_response.status).to eq(200)
      expected_hash = article_params['article'].merge('id' => Article.last.id.to_s)
      expect(json).to eq(expected_hash)
    end

    it 'create' do
      post "/api/v1/articles", article_params
      expect(last_response.status).to eq(201)
      expected_hash = article_params['article'].merge('id' => Article.last.id.to_s)
      expect(json).to eq(expected_hash)
    end

    it 'update' do
      op = create_article(@user, article_params['article'])
      article_params['article']['title'] = 'Updated title'
      put "/api/v1/articles/#{op.model.id}", article_params
      expect(last_response.status).to eq(401)
      expect(Article.last).to_not eq('Updated title')
    end

    it 'delete' do
      op = create_article(@user, article_params['article'])

      delete "/api/v1/articles/#{op.model.id}", article_params
      expect(last_response.status).to eq(401)
      expect(Article.find(op.model.id)).to eq(op.model)
    end
  end

  describe 'authenticated user creator' do
    before(:each) do
      @user = create_user.model
      sign_in(@user)
    end

    it 'index' do
      1.upto(10) do |i|
        create_article(@user, article_params['article'])
      end
      get "/api/v1/articles"
      expect(last_response.status).to eq(200)
      expected_hash = {}
      expected_hash['articles'] = Article.all.map do |a|
        article_params['article'].merge({ 'id' => a.id.to_s })
      end
      expect(json).to eq(expected_hash)
    end

    it 'get existing' do
      op = create_article(@user, article_params['article'])
      get "/api/v1/articles/#{op.model.id}"
      expect(last_response.status).to eq(200)
      expected_hash = article_params['article'].merge('id' => Article.last.id.to_s)
      expect(json).to eq(expected_hash)
    end

    it 'create' do
      post "/api/v1/articles", article_params
      expect(last_response.status).to eq(201)
      expected_hash = article_params['article'].merge('id' => Article.last.id.to_s)
      expect(json).to eq(expected_hash)
    end

    it 'create with invalid' do
      article_params['article']['title'] = nil
      article_params['article']['body'] = 'a' * 1001
      post "/api/v1/articles", article_params
      expect(last_response.status).to eq(422)
      expected_hash = {
          "errors"=>[
              {"title"=>["can't be blank", "is too short (minimum is 10 characters)"]},
              {"body"=>["is too long (maximum is 1000 characters)"]}
          ]
      }
      expect(json).to eq(expected_hash)
    end

    it 'update' do
      op = create_article(@user, article_params['article'])
      article_params['article']['title'] = 'Updated title'
      put "/api/v1/articles/#{op.model.id}", article_params
      expect(last_response.status).to eq(200)
      expected_hash = article_params['article'].merge('id' => Article.last.id.to_s, 'title' => 'Updated title')
      expect(json).to eq(expected_hash)
    end

    it 'update with invalid' do
      op = create_article(@user, article_params['article'])
      article_params['article']['title'] = ''
      article_params['article']['body'] = ''
      put "/api/v1/articles/#{op.model.id}", article_params
      expect(last_response.status).to eq(422)
      expected_hash = {
          "errors"=>[
              {"title"=>["can't be blank", "is too short (minimum is 10 characters)"]},
              {"body"=>["can't be blank"]}
          ]
      }
      expect(json).to eq(expected_hash)
    end

    it 'delete' do
      op = create_article(@user, article_params['article'])

      delete "/api/v1/articles/#{op.model.id}", article_params
      expect(last_response.status).to eq(200)
      expect {Article.find(op.model.id)}.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end

  describe 'authenticated user not creator admin' do
    before(:each) do
      @user = create_user.model
      @admin = create_user_admin.model
      sign_in(@admin)
    end

    it 'index' do
      1.upto(10) do |i|
        create_article(@user, article_params['article'])
      end
      get "/api/v1/articles"
      expect(last_response.status).to eq(200)
      expected_hash = {}
      expected_hash['articles'] = Article.all.map do |a|
        article_params['article'].merge({ 'id' => a.id.to_s })
      end
      expect(json).to eq(expected_hash)
    end

    it 'get existing' do
      op = create_article(@user, article_params['article'])
      get "/api/v1/articles/#{op.model.id}"
      expect(last_response.status).to eq(200)
      expected_hash = article_params['article'].merge('id' => Article.last.id.to_s)
      expect(json).to eq(expected_hash)
    end

    it 'create' do
      post "/api/v1/articles", article_params
      expect(last_response.status).to eq(201)
      expected_hash = article_params['article'].merge('id' => Article.last.id.to_s)
      expect(json).to eq(expected_hash)
    end

    it 'update' do
      op = create_article(@user, article_params['article'])
      article_params['article']['title'] = 'Updated title'
      put "/api/v1/articles/#{op.model.id}", article_params
      expect(last_response.status).to eq(200)
      expected_hash = article_params['article'].merge('id' => Article.last.id.to_s, 'title' => 'Updated title')
      expect(json).to eq(expected_hash)
    end

    it 'delete' do
      op = create_article(@user, article_params['article'])

      delete "/api/v1/articles/#{op.model.id}", article_params
      expect(last_response.status).to eq(200)
      expect {Article.find(op.model.id)}.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end

end