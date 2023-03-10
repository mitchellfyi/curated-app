# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
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

  def new?
    create?
  end

  def update?
    user.present? &&
      (
        user.has_role?(:owner, record) ||
        user.has_role?(:staff, record) ||
        user.has_role?(:developer) ||
        user.has_role?(:staff)
      )
  end

  def edit?
    update?
  end

  def destroy?
    user.present? &&
      (
        user.has_role?(:owner, record) ||
        user.has_role?(:developer) ||
        user.has_role?(:staff)
      )
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
      # raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
