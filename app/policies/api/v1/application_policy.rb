module Api::V1
  class ApplicationPolicy
    attr_reader :user, :model

    def initialize(user, model)
      @user = user
      @model = model
    end

    def index?
      true
    end

    def show?
      true
    end

    def create?
      user.present?
    end

    def update?
      user.present? && (user_owner? || user.is_admin)
    end

    def user_owner?
      user == model.user
    end

    def delete?
      update?
    end

  end
end