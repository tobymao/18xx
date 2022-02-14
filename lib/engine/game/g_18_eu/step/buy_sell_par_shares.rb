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
            return false if exchange &&
                            (bought? ||
                             !bundle.corporation.ipoed ||
                             @game.corporations_operated.include?(bundle.corporation))

            super
          end

          def can_buy_any?(entity)
            return false if bought?

            super || can_exchange?(entity)
          end

          def check_legal_buy(entity, shares, exchange: nil, swap: nil, allow_president_change: true)
            raise GameError, "Cannot buy a share of #{shares&.corporation&.name}" if
                !can_buy?(entity, shares.to_bundle) && !swap && !exchange
          end

          def can_exchange?(entity)
            return true if @game.loading
            return true if @game.corporations.any? { |c| @game.can_par?(c, entity) }

            @game.minors.any? { |m| m.owner == entity && can_exchange_minor?(m) }
          end

          def can_exchange_minor?(minor)
            return true if @game.loading

            connected = connected_corporations(minor)
            return false if connected.empty?

            connected.any? { |c| !@game.corporations_operated.include?(c) }
          end
        end
      end
    end
  end
end
