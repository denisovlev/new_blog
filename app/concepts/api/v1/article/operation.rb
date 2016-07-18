module Api::V1
  module Article

    class Show < Trailblazer::Operation
      include Model
      model ::Article, :find

      extend Trailblazer::Operation::Representer::DSL
      include Trailblazer::Operation::Representer::Rendering
      representer Api::V1::Article::Representer::Show

      def process(*)
      end

    end

    class Create < Show
      model ::Article, :create

      contract do
        property :title
        property :body

        validates :title, presence: true, length: {minimum: 10, maximum: 100}
        validates :body, presence: true, length: {maximum: 1000}
      end

      def process(params)
        validate(params['article']) do |f|
          f.save
        end
      end

    end

    class Update < Create
      include Model
      model ::Article, :update
    end

    class Delete < Show
      def process(*)
        model.destroy
      end
    end

  end
end