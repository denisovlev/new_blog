module Api::V1
  module User
    class Show < Trailblazer::Operation
      include Model
      model ::User, :find

      extend Trailblazer::Operation::Representer::DSL
      include Trailblazer::Operation::Representer::Rendering
      representer Api::V1::User::Representer::Show

      def process(*)
      end

    end

    class Create < Show
      model ::User, :create

      contract do
        property :email
        property :password, virtual: true
        property :password_confirmation, virtual: true

        validates :email, presence: true
        validates :password, presence: true, length: {minimum: 6}
        validate :password_ok?

        def password_ok?
          return unless email and password
          return if password == password_confirmation
          errors.add(:password, 'Passwords do not match')
        end
      end

      def process(params)
        validate(params['user']) do |f|
          create!
          f.save
        end
      end

      def create!
        auth = Tyrant::Authenticatable.new(contract.model)
        auth.digest!(contract.password)
        auth.confirmed!
        auth.sync
      end

    end

    class Update < Create
      model ::User, :update
    end

  end
end