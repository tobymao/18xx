# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/issuer'

module View
  module Game
    class BuySellBonds < Snabberb::Component
      include Actionable

      needs :issuer

      def render
        @step = @game.round.active_step
        @current_entity = @step.current_entity

        @pool_bonds = @issuer.bonds.select { |b| b.owner == @issuer }

        children = []

        children.concat(render_buy_market_bonds)
        children.concat(render_sell_bonds)

        children.compact!
        return h(:div, children) unless children.empty?

        nil
      end

      def render_buy_market_bonds
        return [] unless @step.current_actions.include?('buy_bonds')

        @game.bundles_for_issuer(@issuer, @issuer).map do |bundle|
          next unless @step.can_buy_bonds?(@current_entity, bundle)

          h(:button, { on: { click: -> { buy_bonds(@current_entity, bundle) } } }, button_text('Buy', bundle))
        end
      end

      def render_sell_bonds
        return [] unless @step.current_actions.include?('sell_bonds')

        @game.sellable_bond_bundles(@current_entity, @issuer).map do |bundle|
          next unless @step.can_sell_bonds?(@current_entity, bundle)

          h(:button, { on: { click: -> { sell_bonds(@current_entity, bundle) } } }, button_text('Sell', bundle))
        end
      end

      private

      def button_text(action, bundle)
        text = "#{action} #{bundle.count} Bond"
        text += 's' if bundle.count > 1
        text + " (#{@game.format_currency(bundle.value)})"
      end

      def sell_bonds(entity, bundle)
        process_action(Engine::Action::SellBonds.new(entity, bonds: bundle.bonds))
      end

      def buy_bonds(entity, bundle)
        process_action(Engine::Action::BuyBonds.new(entity, bonds: bundle.bonds))
      end
    end
  end
end
