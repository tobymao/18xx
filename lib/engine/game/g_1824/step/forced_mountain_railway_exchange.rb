# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1824
      module Step
        class ForcedMountainRailwayExchange < Engine::Step::BuySellParShares
          ACTIONS = %w[buy_shares pass].freeze

          def actions(_entity)
            return [] if exchangables.empty?

            ACTIONS
          end

          def active_entities
            exchangables.take(1).map(&:owner)
          end

          def override_entities
            exchangables.map(&:owner)
          end

          def show_other_players
            true
          end

          def active?
            !exchangables.empty?
          end

          def blocking?
            !exchangables.empty?
          end

          def description
            'Exchange'
          end

          def pass_description
            "Discard Mountain Railway #{mountain_railway.name}"
          end

          def exchangables
            @game.forced_mountain_railway_exchange
          end

          def mountain_railway
            exchangables.take(1).first
          end

          def can_buy?(_entity, _bundle)
            # No buy shares allowed in this step, only exchange
            false
          end

          def can_sell?(_entity, _bundle)
            # No sell shares allowed in this step, only exchange
            false
          end

          def can_gain?(entity, bundle, exchange: false)
            super && @game.buyable?(bundle.corporation)
          end

          def can_exchange?(entity, bundle = nil)
            return false unless (ability = @game.abilities(entity, :exchange))
            return can_gain?(entity.owner, bundle, exchange: true) if bundle

            shares = []
            @game.exchange_corporations(ability).each do |corporation|
              shares << corporation.available_share if ability.from.include?(:ipo)
              shares << @game.share_pool.shares_by_corporation[corporation]&.first if ability.from.include?(:market)
            end

            shares.any? { |s| can_gain?(entity.owner, s&.to_bundle, exchange: true) }
          end

          def process_buy_shares(action)
            company = action.entity
            player = company.owner
            bundle = action.bundle
            raise GameError, "Cannot exchange #{company.id} for #{bundle.corporation.id}" unless can_exchange?(company, bundle)

            bundle.share_price = 0
            @game.share_pool.buy_shares(player, bundle, exchange: company, exchange_price: 0)
            company.close!
            @game.forced_mountain_railway_exchange.shift
          end

          def process_pass(action)
            player = action.entity
            company = mountain_railway
            company.close!
            @log << "#{player.name} discards #{company.id} without any compensation"
            @game.forced_mountain_railway_exchange.shift
          end

          def redeemable_shares(_entity)
            # Just to make it compile - redeem is not used in 1824
            []
          end
        end
      end
    end
  end
end
