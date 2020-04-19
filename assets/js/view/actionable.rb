# frozen_string_literal: true

require 'engine/game_error'

module View
  module Actionable
    def self.included(base)
      base.needs :game, store: true
      base.needs :flash_opts, default: {}, store: true
      base.needs :connection, store: true, default: nil
    end

    def process_action(action)
      store(:game, @game.process_action(action))
      @connection&.send('action', action.to_h)
    rescue StandardError => e
      store(:game, @game.clone(@game.actions), skip: true)
      store(:flash_opts, e.message)
      e.backtrace.each { |line| puts line }
    end

    def rollback
      store(:game, @game.rollback)
      @connection&.send('rollback')
    end
  end
end
