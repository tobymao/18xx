# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1866
      module Step
        class LoanInterestPayment < Engine::Step::Base
          def actions(_entity)
            []
          end

          def skip!
            pass!

            entity = current_entity
            return unless (owed = @game.pay_interest!(entity))

            player = entity.owner
            remaining = owed - entity.cash
            entity.spend(entity.cash, @game.bank) if entity.cash.positive?
            @game.player_spend(player, remaining)
            @log << "#{player.name} pays the remaining interest #{@game.format_currency(remaining)} for #{entity.name}"
          end
        end
      end
    end
  end
end
