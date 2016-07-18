module Api::V1
  module Article

    class Show < Trailblazer::Operation
      include Model
      model ::Article, :find

      include Trailblazer::Operation::Representer
      representer do
        property :id
        property :title
        property :body
      end

      def process(*)
      end

    end

    class Create < Trailblazer::Operation
      include Model
      model ::Article, :create

      contract do
        property :title
        property :body

        validates :title, presence: true, length: {minimum: 10, maximum: 100}
        validates :body, presence: true, length: {maximum: 1000}
      end

      include Trailblazer::Operation::Representer
      representer do
        property :id
      end

      def process(params)
        validate(params[:article]) do |f|
          f.save
        end
      end

    end
  end
end