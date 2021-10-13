# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/exchange'
require_relative 'buy_sell_par_shares'

module Engine
  module Game
    module G1828
      module Step
        class Exchange < Engine::Step::Exchange
          def actions(entity)
            return super unless @entity

            entity == @entity ? %w[par] : []
          end

          def description
            @entity ? 'Choose Corporation Par Value' : super
          end

          def active_entities
            @entity ? [@entity] : super
          end

          def blocking?
            @entity || super
          end

          def process_buy_shares(action)
            company = action.entity
            bundle = action.bundle

            if @round.stock?
              if @round.current_entity != company.owner
                raise GameError, "Must use #{company.name} on your turn when in a stock round"
              end
              raise GameError, 'Cannot exchange and buy on the same turn' if bought?
            end

            if !bundle.presidents_share
              corporation = bundle.shares.first.corporation
              already_floated = corporation.floated?

              super

              @round.current_actions << action if @round.stock?

              # Corporation operates at the start of the operating round where it floated
              if @round.operating? && @game.round_start? && !already_floated && corporation.floated?
                @round.entities.replace(@round.select_entities)
              end
            else
              @corporation = bundle.presidents_share.corporation
              @entity = company.owner

              raise GameError, "#{@entity.name} cannot par #{@corporation.name}" unless @game.can_par?(@corporation, @entity)
              unless cash_to_par?(@entity, @corporation)
                raise GameError, "#{@entity.name} does not have enough cash to par #{@corporation.name}"
              end

              company.close!
            end
          end

          def process_par(action)
            raise GameError, "Must par #{@corporation.name}" unless action.corporation == @corporation
            raise GameError, "Only #{@entity.name} can par" unless action.entity == @entity

            share_price = action.share_price

            @game.stock_market.set_par(@corporation, share_price)
            bundle = @corporation.presidents_share.to_bundle
            @game.share_pool.buy_shares(@entity,
                                        bundle,
                                        exchange: true,
                                        exchange_price: bundle.price_per_share)

            @round.current_actions(action) if @round.stock?

            @entity = nil
            @corporation = nil
          end

          def can_exchange?(entity, bundle = nil)
            super && (!@round.stock? || !bought?)
          end

          def corporation_pending_par
            @corporation
          end

          def get_par_prices(entity, _corporation)
            @game.par_prices.select { |p| p.price <= entity.cash }
          end

          def cash_to_par?(entity, corporation)
            !get_par_prices(entity, corporation).empty?
          end

          def can_gain?(entity, bundle, exchange: false)
            return false unless bundle.buyable
            return true if exchange

            super
          end

          def bought?
            @round.current_actions.any? { |x| BuySellParShares::PURCHASE_ACTIONS.include?(x.class) }
          end
        end
      end
    end
  end
end
