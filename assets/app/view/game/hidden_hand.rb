# frozen_string_literal: true

require 'view/game/unsold_companies'
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
      needs :hide_hand, default: true, store: true

      def render
        @round = @game.round
        @current_entity = @round.current_entity

        user_name = @user&.dig('name')
        user_is_player = !hotseat? && user_name && @game.players.map(&:name).include?(user_name)
        @user_is_current_player = user_is_player && @current_entity.name == user_name
        @master_mode = Lib::Storage[@game.id]&.dig('master_mode')
        @block_show = user_is_player && !@user_is_current_player && !Lib::Storage[@game.id]&.dig('master_mode')
        @current_entity_is_player = @current_entity.name == @player.name

        LOGGER.debug "HiddenHand >> @user: #{@user} user_name: #{user_name} user_is_player: #{user_is_player}" \
          " @user_is_current_player: #{@user_is_current_player} hotseat?: #{hotseat?} " \
          " @player: #{@player.name} current_entity: #{@current_entity.name} " \
          " @show_hand: #{@show_hand} @master_mode: #{@master_mode} "

        return h(:div) unless @current_entity_is_player

        children = []
        children << render_show_button if !@block_show
        children << render_companies unless hide_hand?
        h(:div, children)
      end

      def render_companies
        hand_companies = @player.hand

        companies = hand_companies.flat_map do |c|
          h(Company, company: c, layout: :table)
        end

        top_padding = @player.companies.empty? ? '0' : '1em'
        table_props = {
          style: {
            padding: "#{top_padding} 0.5rem 0.2rem",
            grid: @game.show_value_of_companies?(@player) ? 'auto / 1fr auto auto' : 'auto / 1fr auto',
            gap: '0 0.3rem',
          },
        }

        h('div.hand_company_table', table_props, [
          h('div.bold', 'Hidden Hand'),
          @game.show_value_of_companies?(@player) ? h('div.bold.right', 'Value') : '',
          h('div.bold.right', 'Income'),
          *companies,
        ])
      end

      def render_show_button
        return nil if @user_is_current_player

        toggle = lambda do
          if @block_show
            store(:flash_opts, 'Enter master mode to reveal other hand. Use this feature fairly.')
          else
            store(:hide_hand, !@hide_hand)
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

        h(:button, props, "#{hide_hand? ? 'Show' : 'Hide'} Hand")
      end

      def hide_hand?
        return false if @user_is_current_player

        @block_show || @hide_hand
      end
    end
  end
end
