# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative 'minor_exchange'

module Engine
  module Game
    module G18EU
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          include MinorExchange

          def actions(entity)
            actions = super

            actions << 'buy_shares' if entity.minor?

            actions
          end

          def round_state
            super.merge(
              {
                pending_acquisition: nil,
              }
            )
          end

          def process_buy_shares(action)
            entity = action.entity
            if entity.minor?
              exchange_minor(entity, action.bundle)
            else
              buy_shares(entity, action.bundle)
            end

            track_action(action, action.bundle.corporation)
          end

          def exchange_minor(minor, bundle)
            corporation = bundle.corporation
            source = bundle.owner
            unless can_gain?(minor.owner, bundle, exchange: true)
              raise GameError, "#{minor.name} cannot be exchanged for #{corporation.name}"
            end

            exchange_share(minor, corporation, source)
            merge_minor!(minor, corporation, source)
          end

          def can_gain?(entity, bundle, exchange: false)
            return false if exchange && !bundle.corporation.ipoed
            return false if exchange && @game.corporations_operated.include?(bundle.corporation)

            super
          end
        end
      end
    end
  end
end
