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
            return [] unless entity == current_entity

            actions = super.dup
            banater = @game.banater
            return actions unless banater
            return actions if actions.include?('sell_shares') && must_sell?(entity)

            actions << 'pass' if banater.owner == entity && !banater.closed? && !actions.include?('pass')

            actions
          end
        end
      end
    end
  end
end
