# frozen_string_literal: true

class CollectionPolicy < ApplicationPolicy
  def create?
    update?
  end
end
