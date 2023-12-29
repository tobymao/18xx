# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1847AE
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def get_par_prices(_entity, corporation)
            [corporation.par_price]
          end

          def can_buy?(entity, bundle)
            # nationalization - must own 70% of the corporation and pay 150% of CMV
            if bundle.owner.player?
              return false unless can_nationalize?(entity, bundle.corporation)

              return entity.cash >= nationalization_price(bundle.price) &&
                !@round.players_sold[entity][bundle.corporation] &&
                can_gain?(entity, bundle)
            end

            return false unless super

            bundle = bundle.to_bundle
            corporation = bundle.corporation
            cert = bundle.shares.first

            # 2nd and last IPO shares may be double; they must be bought in order
            if cert.owner == corporation.ipo_owner
              # Filter out investor shares
              ipo_shares = corporation.ipo_shares.select(&:buyable)

              return cert.double_cert if corporation.second_share_double && ipo_shares.size == 6

              return cert.double_cert if corporation.last_share_double && ipo_shares.size == 1

              return false if cert.double_cert
            end

            true
          end

          def can_gain?(entity, bundle, exchange: false)
            return false if !bundle || !entity

            corporation = bundle.corporation

            return false if exchange && !@game.can_corporation_have_investor_shares_exchanged?(corporation)

            corporation.holding_ok?(entity, bundle.common_percent) &&
              (exchange || @game.num_certs(entity) < @game.cert_limit(entity))
          end

          def can_buy_any_from_player?(entity)
            return false if bought?

            @game.corporations.select(&:floated?).any? do |corporation|
              can_nationalize?(entity, corporation) && entity.cash >= nationalization_price(corporation.share_price.price)
            end
          end

          def can_nationalize?(player, corporation)
            return false if corporation == @game.lfk

            player.num_shares_of(corporation) >= 7
          end

          def nationalization_price(price)
            (price * 1.5).ceil
          end

          def process_buy_shares(action)
            return super unless action.bundle.owner.player?

            # nationalization
            player = action.entity
            bundle = action.bundle
            price = nationalization_price(bundle.price)
            owner = bundle.owner
            corporation = bundle.corporation

            raise GameError, 'Cannot nationalize this corporation' unless can_nationalize?(player, corporation)
            raise GameError, 'Not enough cash for nationalization' unless player.cash >= price

            @log << "-- Nationalization: #{player.name} buys a #{bundle.percent}% share"\
                    " of #{corporation.name} from #{owner.name} for #{@game.format_currency(price)} --"

            @game.share_pool.transfer_shares(bundle,
                                             player,
                                             spender: player,
                                             receiver: owner,
                                             price: price)

            @game.nationalization_actions_this_round << action
            track_action(action, corporation)
          end

          def can_sell?(entity, bundle)
            # LFK corporation represents a sellable private company
            return true if bundle.corporation == @game.lfk && !bought?

            super
          end

          def action_is_shenanigan?(entity, other_entity, action, corporation, share_to_buy)
            return 'Nationalization' if @game.nationalization_actions_this_round.include?(action)

            super
          end
        end
      end
    end
  end
end
