# frozen_string_literal: true

require_relative 'buy_sell_par_shares'

module Engine
  module Game
    module G1824
      module Step
        class BuySellParExchangeShares < G1824::Step::BuySellParShares
          EXCHANGE_ACTIONS = %w[buy_shares].freeze
          PURCHASE_ACTIONS = Engine::Step::BuySellParShares::PURCHASE_ACTIONS + [Action::SpecialBuy]

          def actions(entity)
            return company_actions(entity) if entity.company?

            player_debt = entity.debt

            actions = super

            # To exchange a coal mine is an available action in case no other action has been done
            # (but we also need to add pass if no actions were allowed)
            if !bought? && !sold? && !buyable_items(entity).empty?
              actions << 'special_buy'
              actions << 'pass' if actions.one?
            end

            # If debt exists, add actions to pay off
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

          def can_buy?(entity, bundle)
            return unless bundle
            return false if entity.debt.positive?
            return false unless super

            bundle = bundle.to_bundle
            corporation = bundle.corporation

            !(@game.staatsbahn?(corporation) && bundle.presidents_share)
          end

          def can_par?(_entity, _parrer)
            true
          end

          def can_sell?(_entity, bundle)
            # Rule VI.8, bullet 1, sub-bullet 2: Bank ownership cannot exceed 50% for started corporations
            # Include bank pool (in case 2-player, 3+ do not use bank pool)
            corp = bundle.corporation
            super && (corp.ipo_shares.sum(&:percent) + corp.percent_in_market + bundle.percent <= 50)
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
              (@game.num_certs(entity) < @game.cert_limit(entity))
          end

          # Needed for two player variant, see Cisleithania implementation
          def allowed_buy_from_market(_entity, _bundle)
            false
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

          def action_is_shenanigan?(entity, other_entity, action, corporation, corp_buying)
            case action
            when Action::SpecialBuy then 'Exchange of Coal Minor'
            when Action::PayoffPlayerDebt then 'Payoff of player debt'
            when Action::PayoffPlayerDebtPartial then 'Partial payoff of player debt'
            else super
            end
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
