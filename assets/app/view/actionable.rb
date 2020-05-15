# frozen_string_literal: true

require 'lib/params'
require 'lib/storage'

module View
  module Actionable
    def self.included(base)
      base.needs :game_data, default: {}, store: true
      base.needs :game, store: true
      base.needs :flash_opts, default: {}, store: true
      base.needs :connection, store: true, default: nil
    end

    def process_action(action)
      if Lib::Params['action']
        return store(:flash_opts, 'You cannot make changes in history mode. Press >| to go current')
      end

      game = @game.process_action(action)
      @game_data[:actions] << action.to_h
      store(:game_data, @game_data, skip: true)

      if @game.finished
        @game_data[:result] = @game.result
        @game_data[:status] = 'finished'
      else
        @game_data[:result] = {}
        @game_data[:status] = 'active'
      end

      if @game_data[:mode] == :hotseat
        Lib::Storage[@game_data[:id]] = @game_data
      else
        json=action.to_h
        meta={
          'game_result': @game_data[:result],
          'game_status': @game_data[:status],
          'active_players': game.active_players.map(&:name),
          'turn': game.turn,
          'round': game.round.name
          }
        json['meta']=meta
        @connection.safe_post("/game/#{@game_data['id']}/action", json)
      end

      store(:game, game)
    rescue StandardError => e
      store(:game, @game.clone(@game.actions), skip: true)
      store(:flash_opts, e.message)
      e.backtrace.each { |line| puts line }
    end
  end
end
