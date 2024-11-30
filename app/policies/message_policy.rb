class MessagePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.viewable_by?(user)
  end

  def create?
    true
  end

  def update?
    record.sender_id == user.id && !record.revoked?
  end

  def destroy?
    record.sender_id == user.id
  end

  def revoke?
    record.sender_id == user.id && !record.revoked?
  end

  def mark_as_read?
    record.recipient_id == user.id && !record.is_read?
  end

  class Scope < Scope
    def resolve
      scope.for_user(user.id)
    end
  end
end 