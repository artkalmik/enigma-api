class UserPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def search?
    true
  end

  class Scope < Scope
    def resolve
      scope.where(status: :active)
    end
  end
end 