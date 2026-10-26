# frozen_string_literal: true

require_relative '../../g_1880/step/buy_sell_par_shares'
require_relative 'parrer'

module Engine
  module Game
    module G1880Romania
      module Step
        class BuySellParShares < G1880::Step::BuySellParShares
          include Parrer

          def actions(entity)
            actions = super
            banater = @game.banater if @game.banater
            # prevents P1. Banater's owner from being skipped in SR for no available actions when they could still use it
            return actions if !actions.empty? || banater.owner != entity || banater.closed?

            %w[pass]
          end
        end
      end
    end
  end
end
