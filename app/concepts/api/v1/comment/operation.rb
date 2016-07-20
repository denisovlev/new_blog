module Api::V1
  module Comment

    class Index < Trailblazer::Operation
      include Collection

      extend Trailblazer::Operation::Representer::DSL
      include Trailblazer::Operation::Representer::Rendering
      representer do
        collection :to_a, as: :comments, embedded: true, decorator: Api::V1::Comment::Representer::Show
      end

      def model!(params)
        ::Comment.where(article_id: params[:article_id])
      end
    end

    class Show < Trailblazer::Operation
      include Model
      model ::Comment, :find

      extend Trailblazer::Operation::Representer::DSL
      include Trailblazer::Operation::Representer::Rendering
      representer Api::V1::Comment::Representer::Show

      include Policy
      policy Api::V1::ApplicationPolicy, :show?

      def process(*)
      end

    end

    class Create < Show
      model ::Comment, :create

      policy Api::V1::ApplicationPolicy, :create?

      contract do
        property :body

        property :article, populator: ->(fragment:, **) {
          article ? article : self.article = ::Article.find(fragment)
        }

        validates :body, presence: true, length: {maximum: 1000}
        validates :article, presence: true
      end

      def process(params)
        comment_params = params['comment']
        comment_params['article'] = params[:article_id]
        validate(comment_params) do |f|
          model.user = params[:current_user]
          f.save
        end
      end
    end

    class Update < Create
      include Model
      model ::Comment, :update

      policy Api::V1::ApplicationPolicy, :update?

      def process(params)
        validate(params['comment']) do |f|
          f.save
        end
      end
    end

    class Delete < Show
      policy Api::V1::ApplicationPolicy, :delete?

      def process(*)
        model.destroy
      end
    end

  end
end