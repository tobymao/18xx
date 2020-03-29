# frozen_string_literal: true

module View
  module Actionable
    def self.included(base)
      base.needs :game, store: true
      base.needs :connection, store: true
    end

    def process_action(action)
      store(:game, @game.process_action(action))
      @connection.send('action', action.to_h)
    end

    def rollback
      store(:game, @game.rollback)
      @connection.send('rollback')
    end
  end
end
