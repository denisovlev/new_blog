module Api::V1
  module User
    class Show < Trailblazer::Operation
      include Model
      model ::User, :find

      extend Trailblazer::Operation::Representer::DSL
      include Trailblazer::Operation::Representer::Rendering
      representer Api::V1::User::Representer::Show

      include Policy
      policy Api::V1::UsersPolicy, :show?

      def process(*)
      end

    end

    require "reform/form/validation/unique_validator.rb"
    class Create < Show
      model ::User, :create

      policy Api::V1::UsersPolicy, :create?

      contract do
        property :email
        property :password, virtual: true
        property :password_confirmation, virtual: true
        property :authentication_token

        validates :email, unique: true
        validates :password, presence: true, length: {minimum: 6}
        validate :password_ok?

        def password_ok?
          return unless email and password
          return if password == password_confirmation
          errors.add(:password, 'Passwords do not match')
        end
      end

      def process(params)
        contract.prepopulate!
        validate(params['user']) do |f|
          create!
          generate_authentication_token!
          f.save
        end
      end

      def create!
        auth = Tyrant::Authenticatable.new(contract.model)
        auth.digest!(contract.password)
        auth.confirmed!
        auth.sync
      end

      def generate_authentication_token!
        loop do
          authentication_token = SecureRandom.base64(64)
          contract.authentication_token = authentication_token
          break unless ::User.where(authentication_token: authentication_token).first.present?
        end
      end

      class Admin < self
        contract do
          property :is_admin, prepopulator: -> (*) { self.is_admin = true }
        end
      end

    end

    class SignIn < Trailblazer::Operation

      contract do
        attr_reader :user

        property :email, virtual: true
        property :password, virtual: true

        validates :email, :password, presence: true
        validate :password_ok?

        def password_ok?
          return unless email.present? && password.present?
          @user = ::User.where(email: email).first
          return errors.add(:email, 'This email is not registered') unless @user
          auth = Tyrant::Authenticatable.new(@user)
          errors.add(:password, 'Invalid password') unless auth.digest?(password)
        end
      end

      extend Trailblazer::Operation::Representer::DSL
      include Trailblazer::Operation::Representer::Rendering
      representer do
        property :id
        property :email
        property :authentication_token
      end

      def process(params)
        validate(params['user']) do
          @model = contract.user
        end
      end
    end

  end
end