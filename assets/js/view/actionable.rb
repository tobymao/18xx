# frozen_string_literal: true

module View
  module Actionable
    def self.included(base)
      base.needs :game, store: true
    end

    def process_action(action)
      @game.process_action(action)
      store(:game, @game)
    end

    def rollback
      store(:game, @game.rollback)
    end
  end
end
