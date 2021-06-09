# frozen_string_literal: true

require_relative '../../../step/bankrupt'

module Engine
  module Game
    module G1856
      module Step
        class Bankrupt < Engine::Step::Bankrupt
          def active?
            active_entities.any?
          end

          def actions(entity)
            return [] if entity.company?

            ACTIONS
          end

          def active_entities
            return [] unless @round.cash_crisis_player

            [@round.cash_crisis_player]
          end

          def process_bankrupt(action)
            player = action.entity.player? ? action.entity : action.entity.owner

            @log << "-- #{player.name} goes bankrupt --"

            player.shares_by_corporation(sorted: true).each do |corporation, _|
              next unless corporation.share_price # if a corporation has not parred

              # Do a potential repeated sell of bundles. This is important for NdM in 18MEX
              # which might have 5% bundle(s) besides the 10%+ bundles.
              # Most other titles this will just sell one, the largest, bundle.
              while (bundle = @game.sellable_bundles(player, corporation).max_by(&:price))
                @game.sell_shares_and_change_price(bundle)
              end
            end
            @round.recalculate_order if @round.respond_to?(:recalculate_order)

            player.spend(player.cash, @game.bank, check_positive: false)

            @game.declare_bankrupt(player)
          end
        end
      end
    end
  end
end
