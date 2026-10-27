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
            actions = super.dup
            return actions unless @game.banater

            actions << 'pass' if banater.owner == entity && !banater.closed? && !actions.include?('pass')

            actions
          end
        end
      end
    end
  end
end
