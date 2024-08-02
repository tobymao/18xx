# frozen_string_literal: true

require 'view/game/company'
require 'view/game/actionable'

module View
  module Game
    class HiddenHand < Snabberb::Component
      include Actionable

      needs :player
      needs :game
      needs :user
      needs :flash_opts, default: {}, store: true
      needs :show_hand, default: false, store: true

      def render
        @round = @game.round
        @current_entity = @round.current_entity

        user_name = @user&.dig('name')
        user_in_game = !hotseat? && user_name && @game.players.map(&:name).include?(user_name)
        user_is_this_player = user_name == @player.name && !hotseat?
        current_entity_is_this_player = @current_entity&.name == @player.name
        master_mode = Lib::Storage[@game.id]&.dig('master_mode')
        user_in_master_mode = user_in_game && master_mode && current_entity_is_this_player

        @show_button = user_is_this_player || (current_entity_is_this_player && hotseat?)
        @can_use_button = user_is_this_player || user_in_master_mode || hotseat?

        children = []
        children << render_show_button if @show_button
        children << h(CompaniesTable, game: @game, companies: @player.hand, title: 'Hidden Hand') if @show_button && show_hand?
        h(:div, children)
      end

      def render_show_button
        toggle = lambda do
          if @can_use_button
            store(:show_hand, !@show_hand)
          else
            store(:flash_opts, 'Enter master mode to reveal other hand. Use this feature fairly.')
          end
        end

        props = {
          style: {
            display: 'block',
            width: '8.5rem',
            padding: '0.2rem 0',
            margin: '1rem 0',
          },
          on: { click: toggle },
        }

        h(:button, props, "#{show_hand? ? 'Hide' : 'Show'} Hand")
      end

      def show_hand?
        @show_hand
      end
    end
  end
end
