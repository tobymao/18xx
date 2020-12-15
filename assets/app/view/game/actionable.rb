# frozen_string_literal: true

require 'lib/params'
require 'lib/storage'

module View
  module Game
    module Actionable
      def self.included(base)
        base.needs :game_data, default: {}, store: true
        base.needs :game, store: true
        base.needs :flash_opts, default: {}, store: true
        base.needs :connection, store: true, default: nil
        base.needs :user, store: true, default: nil
        base.needs :tile_selector, default: nil, store: true
        base.needs :selected_company, default: nil, store: true
        base.needs :app_route, default: nil, store: true
        base.needs :round_history, default: nil, store: true
      end

      def save_user_settings(settings)
        @connection.safe_post("/game/#{@game_data['id']}/user_settings", settings)

        @game_data['user_settings'] ||= {}
        @game_data['user_settings'].merge!(settings)
      end

      def participant?
        return @participant if defined?(@participant)

        @participant = (@game.players.map(&:id) + [@game_data['user']['id']]).include?(@user&.dig('id'))
      end

      def process_action(action)
        hotseat = @game_data[:mode] == :hotseat

        if Lib::Params['action']
          return store(:flash_opts, 'You cannot make changes while browsing history.
            Press >| to navigate to the current game action.')
        end

        if !hotseat &&
          !action.free? &&
          participant? &&
          !@game.active_players_id.include?(@user['id'])

          unless Lib::Storage[@game.id]&.dig('master_mode')
            return store(:flash_opts, 'Not your turn. Turn on master mode under the Tools menu to act for others.')
          end

          action.user = @user['id']
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

        if hotseat
          @game_data[:turn] = game.turn
          @game_data[:round] = game.round.name
          @game_data[:acting] = game.active_players_id
          Lib::Storage[@game_data[:id]] = @game_data
        elsif participant?
          json = action.to_h
          if @game_data&.dig('settings', 'pin')
            meta = {
              'game_result': @game_data[:result],
              'game_status': @game_data[:status],
              'active_players': game.active_players_id,
              'turn': game.turn,
              'round': game.round.name,
            }
            json['meta'] = meta
          end
          @connection.safe_post("/game/#{@game_data['id']}/action", json)
        else
          store(
            :flash_opts,
            'You are not in this game. Moves are temporary. You can clone this game in the tools tab.',
            skip: true,
          )
        end

        clear_ui_state
        store(:game, game)
      rescue StandardError => e
        store(:game, @game.clone(@game.actions), skip: true)
        store(:flash_opts, e.message)
        e.backtrace.each { |line| puts line }
      end

      def clear_ui_state
        store(:selected_company, nil, skip: true)
        store(:tile_selector, nil, skip: true)
      end

      def history_link(text, title, action_id = nil, style_extra = {})
        route = Lib::Params.add(@app_route, 'action', action_id)

        click = lambda do
          store(:round_history, @game.round_history, skip: true) unless @round_history
          store(:round_history, nil, skip: true) unless action_id
          store(:app_route, route)
          clear_ui_state
        end

        h(
          Link,
          href: route,
          click: click,
          title: title,
          children: text,
          style: {
            color: 'currentColor',
            textDecoration: 'none',
            **style_extra,
          },
        )
      end
    end
  end
end
