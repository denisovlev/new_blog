require 'rails_helper'

RSpec.describe 'comments', :type => :request do

  let(:model_params) {
    {'comment' => {
        'body' => 'some text body'
    }}
  }

  describe 'unauthenticated guest' do
    before(:each) do
      @user = create_user.model
      @article = create_article(@user).model
      @expected_comment_hash = model_params['comment'].merge({
                                                                 'article_id' => @article.id.to_s,
                                                                 'user_id' => @user.id.to_s
                                                             })
    end

    it 'index' do
      1.upto(10) do |i|
        create_comment(@user, @article, model_params['comment'])
      end
      get "/api/v1/articles/#{@article.id.to_s}/comments"
      expect(last_response.status).to eq(200)
      expected_hash = {}
      expected_hash['comments'] = Comment.where(article_id: @article.id).all.map do |a|
        @expected_comment_hash.merge({ 'id' => a.id.to_s})
      end
      expect(json).to eq(expected_hash)
    end

    it 'get existing' do
      op = create_comment(@user, @article, model_params['comment'])
      get "/api/v1/articles/#{@article.id.to_s}/comments/#{op.model.id}"
      expect(last_response.status).to eq(200)
      expected_hash = @expected_comment_hash.merge('id' => Comment.last.id.to_s)
      expect(json).to eq(expected_hash)
    end

    it 'create' do
      post "/api/v1/articles/#{@article.id.to_s}/comments", model_params
      expect(last_response.status).to eq(401)
    end

    it 'update' do
      op = create_comment(@user, @article, model_params['comment'])
      model_params['comment']['body'] = 'Updated title'
      put "/api/v1/articles/#{@article.id.to_s}/comments/#{op.model.id}", model_params
      expect(last_response.status).to eq(401)
      expect(Comment.last.body).to eq('some text body')
    end

    it 'delete' do
      op = create_comment(@user, @article, model_params['comment'])

      delete "/api/v1/articles/#{@article.id.to_s}/comments/#{op.model.id}", model_params
      expect(last_response.status).to eq(401)
      expect(Comment.find(op.model.id)).to eq(op.model)
    end
  end

  describe 'authenticated user not creator' do
    before(:each) do
      @user = create_user.model
      @article = create_article(@user).model
      @user2 = create_user('email' => 'user2@example.com').model
      sign_in(@user2)
      @expected_comment_hash = model_params['comment'].merge({
                                                                 'article_id' => @article.id.to_s,
                                                                 'user_id' => @user.id.to_s
                                                             })
    end

    it 'index' do
      1.upto(10) do |i|
        create_comment(@user, @article, model_params['comment'])
      end
      get "/api/v1/articles/#{@article.id.to_s}/comments"
      expect(last_response.status).to eq(200)
      expected_hash = {}
      expected_hash['comments'] = Comment.where(article_id: @article.id).all.map do |a|
        @expected_comment_hash.merge({ 'id' => a.id.to_s})
      end
      expect(json).to eq(expected_hash)
    end

    it 'get existing' do
      op = create_comment(@user, @article, model_params['comment'])
      get "/api/v1/articles/#{@article.id.to_s}/comments/#{op.model.id}"
      expect(last_response.status).to eq(200)
      expected_hash = @expected_comment_hash.merge('id' => Comment.last.id.to_s)
      expect(json).to eq(expected_hash)
    end

    it 'create' do
      post "/api/v1/articles/#{@article.id.to_s}/comments", model_params
      expect(last_response.status).to eq(201)
      expected_hash = @expected_comment_hash.merge('id' => Comment.last.id.to_s, 'user_id' => @user2.id.to_s)
      expect(json).to eq(expected_hash)
    end

    it 'update' do
      op = create_comment(@user, @article, model_params['comment'])
      model_params['comment']['body'] = 'Updated title'
      put "/api/v1/articles/#{@article.id.to_s}/comments/#{op.model.id}", model_params
      expect(last_response.status).to eq(401)
      expect(Comment.last.body).to eq('some text body')
    end

    it 'delete' do
      op = create_comment(@user, @article, model_params['comment'])

      delete "/api/v1/articles/#{@article.id.to_s}/comments/#{op.model.id}", model_params
      expect(last_response.status).to eq(401)
      expect(Comment.find(op.model.id)).to eq(op.model)
    end
  end

  describe 'authenticated user creator' do
    before(:each) do
      @user = create_user.model
      @article = create_article(@user).model
      sign_in(@user)
      @expected_comment_hash = model_params['comment'].merge({
          'article_id' => @article.id.to_s,
          'user_id' => @user.id.to_s
      })
    end

    it 'index' do
      1.upto(10) do |i|
        create_comment(@user, @article, model_params['comment'])
      end
      get "/api/v1/articles/#{@article.id.to_s}/comments"
      expect(last_response.status).to eq(200)
      expected_hash = {}
      expected_hash['comments'] = Comment.where(article_id: @article.id).all.map do |a|
        @expected_comment_hash.merge({ 'id' => a.id.to_s})
      end
      expect(json).to eq(expected_hash)
    end

    it 'get existing' do
      op = create_comment(@user, @article, model_params['comment'])
      get "/api/v1/articles/#{@article.id.to_s}/comments/#{op.model.id}"
      expect(last_response.status).to eq(200)
      expected_hash = @expected_comment_hash.merge('id' => Comment.last.id.to_s)
      expect(json).to eq(expected_hash)
    end

    it 'create' do
      post "/api/v1/articles/#{@article.id.to_s}/comments", model_params
      expect(last_response.status).to eq(201)
      expected_hash = @expected_comment_hash.merge('id' => Comment.last.id.to_s)
      expect(json).to eq(expected_hash)
    end

    it 'create with invalid' do
      model_params['comment']['body'] = 'a' * 1001
      post "/api/v1/articles/#{@article.id.to_s}/comments", model_params
      expect(last_response.status).to eq(422)
      expected_hash = {
          "errors"=>[
              {"body"=>["is too long (maximum is 1000 characters)"]}
          ]
      }
      expect(json).to eq(expected_hash)
    end

    it 'update' do
      op = create_comment(@user, @article, model_params['comment'])
      model_params['comment']['body'] = 'Updated title'
      put "/api/v1/articles/#{@article.id.to_s}/comments/#{op.model.id}", model_params
      expect(last_response.status).to eq(200)
      expected_hash = @expected_comment_hash.merge('id' => Comment.last.id.to_s, 'body' => 'Updated title')
      expect(json).to eq(expected_hash)
    end

    it 'update with invalid' do
      op = create_comment(@user, @article, model_params['comment'])
      model_params['comment']['body'] = ''
      put "/api/v1/articles/#{@article.id.to_s}/comments/#{op.model.id}", model_params
      expect(last_response.status).to eq(422)
      expected_hash = {
          "errors"=>[
              {"body"=>["can't be blank"]}
          ]
      }
      expect(json).to eq(expected_hash)
    end

    it 'delete' do
      op = create_comment(@user, @article, model_params['comment'])

      delete "/api/v1/articles/#{@article.id.to_s}/comments/#{op.model.id}", model_params
      expect(last_response.status).to eq(200)
      expect {Comment.find(op.model.id)}.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end

  describe 'authenticated user admin not creator' do
    before(:each) do
      @user = create_user.model
      @admin = create_user_admin.model
      @article = create_article(@user).model
      sign_in(@admin)
      @expected_comment_hash = model_params['comment'].merge({
                                                                 'article_id' => @article.id.to_s,
                                                                 'user_id' => @user.id.to_s
                                                             })
    end

    it 'index' do
      1.upto(10) do |i|
        create_comment(@user, @article, model_params['comment'])
      end
      get "/api/v1/articles/#{@article.id.to_s}/comments"
      expect(last_response.status).to eq(200)
      expected_hash = {}
      expected_hash['comments'] = Comment.where(article_id: @article.id).all.map do |a|
        @expected_comment_hash.merge({ 'id' => a.id.to_s})
      end
      expect(json).to eq(expected_hash)
    end

    it 'get existing' do
      op = create_comment(@user, @article, model_params['comment'])
      get "/api/v1/articles/#{@article.id.to_s}/comments/#{op.model.id}"
      expect(last_response.status).to eq(200)
      expected_hash = @expected_comment_hash.merge('id' => Comment.last.id.to_s)
      expect(json).to eq(expected_hash)
    end

    it 'create' do
      post "/api/v1/articles/#{@article.id.to_s}/comments", model_params
      expect(last_response.status).to eq(201)
      expected_hash = @expected_comment_hash.merge('id' => Comment.last.id.to_s, 'user_id' => @admin.id.to_s)
      expect(json).to eq(expected_hash)
    end

    it 'update' do
      op = create_comment(@user, @article, model_params['comment'])
      model_params['comment']['body'] = 'Updated title'
      put "/api/v1/articles/#{@article.id.to_s}/comments/#{op.model.id}", model_params
      expect(last_response.status).to eq(200)
      expected_hash = @expected_comment_hash.merge('id' => Comment.last.id.to_s, 'body' => 'Updated title')
      expect(json).to eq(expected_hash)
    end

    it 'delete' do
      op = create_comment(@user, @article, model_params['comment'])

      delete "/api/v1/articles/#{@article.id.to_s}/comments/#{op.model.id}", model_params
      expect(last_response.status).to eq(200)
      expect {Comment.find(op.model.id)}.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end

end