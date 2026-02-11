# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18Cuba
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def process_par(action)
            raise GameError, 'Cannot par on behalf of other entities' if action.purchase_for

            corporation = action.corporation
            entity = action.entity

            raise GameError, "#{corporation.name} cannot be parred" unless @game.can_par?(corporation, entity)

            return super unless corporation.type == :minor

            par_minor_via_concession(action)
          end

          def par_minor_via_concession(action)
            # sets minor par, exchanges a concession for shares, updates ownership, closes concession, and applies discounts
            corporation = action.corporation
            entity = action.entity
            share_price = action.share_price

            @game.stock_market.set_par(corporation, share_price)

            bundle = minor_starting_bundle(corporation)
            concession = exchange_concession(entity)
            raise GameError, 'No concession available for exchange' unless concession

            exchange_discount = concession.discount || 0

            exchange_price = (share_price.price * bundle.num_shares) - exchange_discount
            raise GameError, 'Not enough cash to par this minor' if entity.cash < exchange_price

            @round.players_bought[entity][corporation] += bundle.percent

            buy_shares(
                entity,
                bundle,
                exchange: concession,
                exchange_price: exchange_price,
              )

            reserve_ipo_shares(corporation)

            remove_exchange_ability(concession)
            close_concession_if_applicable(concession)

            @game.after_par(corporation)
            @game.bank.spend(exchange_discount, corporation)

            track_action(action, corporation)
          end

          def reserve_ipo_shares(corporation)
            shares = corporation.ipo_shares
            shares.each { |s| s.buyable = false }
          end

          def available_par_cash(entity, corporation, share_price: nil)
            # UI: Includes concession discount when calculating which par prices are affordable.
            return entity.cash unless corporation.type == :minor

            concession = exchange_concession(entity)
            return entity.cash unless concession

            entity.cash + (concession.discount || 0)
          end

          def get_par_prices(entity, corporation)
            # Only show par prices where the player can afford the full bundle
            if corporation.type == :minor
              concession = exchange_concession(entity)
              available_cash = entity.cash + (concession&.discount || 0)

              # Minor starting bundle size: number of shares required
              bundle_size = minor_starting_bundle(corporation).num_shares

              @game.stock_market.par_prices.select do |p|
                (p.price * bundle_size) <= available_cash
              end
            else
              # Normal corporations: just check cash vs price
              @game.stock_market.par_prices.select { |p| p.price <= entity.cash }
            end
          end

          def available_cash(entity)
            # For minors, include concession discount in available cash calculation for parring.
            cash = entity.cash

            concession = exchange_concession(entity)
            cash += concession.discount || 0 if concession

            cash
          end

          def minor_starting_bundle(corporation)
            shares = corporation.ipo_shares.take(2)
            ShareBundle.new(shares)
          end

          def exchange_concession(entity)
            # Retrieve concession by looking for a company with an exchange ability owned by the entity
            entity.companies.find { |c| @game.abilities(c, :exchange) }
          end

          def remove_exchange_ability(concession)
            ability = concession.abilities.find { |a| a.type == :exchange }
            return unless ability

            concession.remove_ability(ability)
            concession.value = 0
          end

          def close_concession_if_applicable(concession)
            concession.close! unless special_abilities?(concession)
          end

          def special_abilities?(company)
            company.abilities.any? { |a| a.type != :exchange }
          end
        end
      end
    end
  end
end
