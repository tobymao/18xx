# frozen_string_literal: true

require_relative 'base'

class GameUser < Base
  many_to_one :game
  many_to_one :user
end
