# frozen_string_literal: true

require_relative '../../../step/bankrupt'

module Engine
  module Game
    module G18NewEngland
      module Step
        class Bankrupt < Engine::Step::Bankrupt
          def process_bankrupt(action)
            corp = action.entity
            player = corp.owner

            unless @game.can_go_bankrupt?(player, corp)
              buying_power = @game.format_currency(@game.total_emr_buying_power(player, corp))
              price = @game.format_currency(@game.depot.min_depot_price)

              msg = "Cannot go bankrupt. #{corp.name}'s cash plus #{player.name}'s cash and "\
                    "sellable shares total #{buying_power}, and the cheapest train in the "\
                    "Depot costs #{price}."
              raise GameError, msg
            end

            player.spend(player.cash, @game.bank) if player.cash.positive?

            @log << "-- #{player.name} goes bankrupt. Any companies with #{player.name} as director will close --"

            @game.corporations.dup.each do |c|
              next unless c.owner == player

              @game.close_corporation(c)
            end
          end
        end
      end
    end
  end
end
