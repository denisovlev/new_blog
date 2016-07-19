module Api::V1
  module Article

    class Show < Trailblazer::Operation
      include Model
      model ::Article, :find

      extend Trailblazer::Operation::Representer::DSL
      include Trailblazer::Operation::Representer::Rendering
      representer Api::V1::Article::Representer::Show

      include Policy
      policy Api::V1::ApplicationPolicy, :show?

      def process(*)
      end

    end

    class Create < Show
      model ::Article, :create

      policy Api::V1::ApplicationPolicy, :create?

      contract do
        property :title
        property :body

        validates :title, presence: true, length: {minimum: 10, maximum: 100}
        validates :body, presence: true, length: {maximum: 1000}
      end

      def process(params)
        model.user = params[:current_user]
        validate(params['article']) do |f|
          f.save
        end
      end

    end

    class Update < Create
      include Model
      model ::Article, :update

      policy Api::V1::ApplicationPolicy, :update?

      def process(params)
        validate(params['article']) do |f|
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