# frozen_string_literal: true

class ItemPolicy < ApplicationPolicy
  def create?
    update?
  end
end
