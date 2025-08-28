# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1824
      module Step
        class BuySellParExchangeShares < Engine::Step::BuySellParShares
          EXCHANGE_ACTIONS = %w[buy_shares].freeze
          BUY_ACTION = %w[special_buy].freeze
          PURCHASE_ACTIONS = Engine::Step::BuySellParShares::PURCHASE_ACTIONS + [Action::SpecialBuy]

          def actions(entity)
            return company_actions(entity) if entity.company?

            player_debt = @game.player_debt(entity)

            actions = super
            actions << 'special_buy' if !actions.empty? && buyable_items(entity)
            if player_debt.positive? && entity.cash.positive?
              actions << 'payoff_player_debt'
              actions << 'payoff_player_debt_partial'
            end

            actions
          end

          def company_actions(entity)
            return EXCHANGE_ACTIONS if @game.mountain_railway?(entity) && @game.mountain_railway_exchangable?

            []
          end

          def visible_corporations
            @game.sorted_corporations.reject { |c| c.type == :minor || c.type == :construction_railway }
          end

          def can_buy?(_entity, bundle)
            super && @game.buyable?(bundle.corporation)
          end

          def can_par?(_entity, _parrer)
            true
          end

          def can_sell?(_entity, bundle)
            # Rule VI.8, bullet 1, sub-bullet 2: Bank ownership cannot exceed 50% for started corporations
            corp = bundle.corporation
            super && @game.buyable?(corp) &&
                    (@game.bond_railway?(corp) || (corp.ipo_shares.sum(&:percent) + bundle.percent <= 50))
          end

          # Rule VI.7, bullet 4: Exchange can take you over 60%
          def check_legal_buy(entity, shares, exchange: nil, swap: nil, allow_president_change: true)
            return if exchange

            super
          end

          # Need special implementation to handle the exchange cases
          # 1. Exchange of coal railway
          # 2. Exchange of mountain railway
          # 3. Rule VI.7, bullet 4: Exchange can take you over 60%
          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity
            return false if bundle.owner.player? && !@game.can_gain_from_player?(entity, bundle)

            corporation = bundle.corporation
            return false if invalid_mountain_railway_exchange?(entity, corporation, exchange)

            (exchange || corporation.holding_ok?(entity, bundle.common_percent) || allowed_buy_from_market(entity, bundle)) &&
              (@game.num_certs(entity) < @game.cert_limit(entity)) && @game.buyable?(corporation)
          end

          # Rule X.4, bullet 2: Maybe exceed 60% in 2 player 1824, if buying from market
          def allowed_buy_from_market(_entity, bundle)
            return false unless @game.two_player?

            bundle.shares.first.owner == @game.share_pool
          end

          def process_buy_shares(action)
            return super unless action.entity.company?

            company = action.entity
            bundle = action.bundle
            bundle.share_price = 0
            buy_shares(company.owner, bundle, exchange: company)
            company.close!

            # Exchange is treated as a Buy, and no more actions allowed as Sell-Buy
            track_action(action, bundle.corporation)
          end

          def buyable_items(entity)
            return [] unless @game.coal_railway_exchangable?

            @game.corporations.select { |c| !c.closed? && @game.coal_railway?(c) && c.owned_by?(entity) }.map do |c|
              Item.new(description: c.id, cost: 0)
            end
          end

          def item_str(item)
            coal_minor = @game.corporation_by_id(item.description)
            regional = @game.get_associated_regional_railway(coal_minor)
            "Exchange #{coal_minor.name} for #{regional.name} presidency"
          end

          def process_special_buy(action)
            coal_minor = @game.corporation_by_id(action.item.description)
            regional = @game.exchange_target(coal_minor)

            @game.exchange_coal_minor(coal_minor)

            # Exchange is treated as a Buy, and no more actions allowed as Sell-Buy
            track_action(action, regional)
          end

          def process_payoff_player_debt(action)
            player = action.entity
            @game.payoff_player_loan(player)
            @round.last_to_act = player
            @round.current_actions << action
          end

          def process_payoff_player_debt_partial(action)
            player = action.entity
            @game.payoff_player_loan(player, payoff_amount: action.amount)
            @round.last_to_act = player
            @round.current_actions << action
          end

          def allow_president_change?(corporation)
            reserved = corporation.reserved_shares
            reserved.none? { |s| s.percent == 20 }
          end

          private

          def exchangable_ability(entity)
            return if !entity.company? || !@game.mountain_railway?(entity) || !@game.mountain_railway_exchangable?

            @game.abilities(entity, :exchange)
          end

          def invalid_mountain_railway_exchange?(entity, corporation, exchange)
            return false unless exchange

            !@game.mountain_railway_exchangable? || !@game.exchangable_for_mountain_railway?(entity, corporation)
          end
        end
      end
    end
  end
end
