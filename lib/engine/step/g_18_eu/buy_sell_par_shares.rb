# frozen_string_literal: true

require_relative '../buy_sell_par_shares'
require_relative 'minor_exchange'

module Engine
  module Step
    module G18EU
      class BuySellParShares < BuySellParShares
        include MinorExchange

        def actions(entity)
          actions = super

          actions << 'buy_shares' if entity.minor?

          actions
        end

        def process_buy_shares(action)
          entity = action.entity
          if entity.minor?
            exchange_minor(entity, action.bundle)
            entity = entity.owner
          else
            buy_shares(entity, action.bundle)
          end

          @round.last_to_act = entity
          @current_actions << action
        end

        def exchange_minor(minor, bundle)
          corporation = bundle.corporation
          unless can_gain?(minor.owner, bundle, exchange: true)
            raise GameError, "#{minor.name} cannot be exchanged for #{corporation.name}"
          end

          exchange_share(minor, corporation)
          merge_minor!(minor, bundle.corporation)
        end

        def can_gain?(entity, bundle, exchange: false)
          return false if exchange && !bundle.corporation.ipoed

          super
        end
      end
    end
  end
end
