# frozen_string_literal: true

require 'view/game/corporation'
require 'view/game/sell_shares'

module View
  module Game
    module EmergencyMoney
      def render_emergency_money_raising(player)
        children = []
        props = {
          style: {
            display: 'inline-block',
            verticalAlign: 'top',
          },
        }
        player.shares_by_corporation.each do |corporation, shares|
          next if shares.empty?

          corp = [h(Corporation, corporation: corporation)]

          corp << h(SellShares, player: player, corporation: corporation) if @selected_corporation == corporation

          children << h(:div, props, corp)
        end

        children << render_bankruptcy if @game.round.steps.find { |s| s.respond_to?(:process_bankrupt) }
        children
      end

      def render_bankruptcy
        resign = lambda do
          process_action(Engine::Action::Bankrupt.new(@game.round.active_step.current_entity))
        end

        props = {
          style: {
            width: 'max-content',
          },
          on: { click: resign },
        }

        h(:button, props, 'Declare Bankruptcy')
      end
    end
  end
end
