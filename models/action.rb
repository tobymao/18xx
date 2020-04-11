# frozen_string_literal: true

require_relative 'base'

class Action < Base
  many_to_one :game
  many_to_one :user

  def to_h
    action.to_h
  end
end
