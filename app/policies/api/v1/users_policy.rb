module Api::V1
  class UsersPolicy < ApplicationPolicy

    def create?
      true
    end

    def update?
      user.present? and (user == model || user.is_admin)
    end

    def delete?
      user.present? and (user.is_admin && !model.is_admin)
    end

  end
end