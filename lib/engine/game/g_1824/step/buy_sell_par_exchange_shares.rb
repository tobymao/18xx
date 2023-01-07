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
            return can_exchange?(entity) ? EXCHANGE_ACTIONS : [] if entity.company?

            actions = super
            actions << 'special_buy' if !actions.empty? && buyable_items(entity)
            actions
          end

          def can_buy?(entity, bundle)
            return if !bundle || !entity
            return if entity.common_percent_of(bundle.corporation) + (bundle.num_shares * 10) > 60

            super && @game.buyable?(bundle.corporation)
          end

          def can_sell?(_entity, bundle)
            super && @game.buyable?(bundle.corporation)
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity || !@game.buyable?(bundle.corporation)
            # Via exchanges it is possible to exceed 60%
            return @game.num_certs(entity) + bundle.num_shares <= @game.cert_limit(entity) if exchange

            super
          end

          def can_exchange?(entity, bundle = nil)
            return false unless (ability = exchangable_ability(entity))
            return can_gain?(entity.owner, bundle, exchange: true) if bundle

            shares = []
            @game.exchange_corporations(ability).each do |corporation|
              shares << corporation.available_share if ability.from.include?(:ipo)
              shares << @game.share_pool.shares_by_corporation[corporation]&.first if ability.from.include?(:market)
            end

            shares.any? { |s| can_gain?(entity.owner, s&.to_bundle, exchange: true) }
          end

          def check_legal_buy(entity, shares, exchange: nil, swap: nil, allow_president_change: true)
            # Via exchanges it is possible to exceed 60%
            corporation = shares.corporation
            return true if exchange && @game.buyable?(corporation) && !@round.players_sold[entity][corporation]

            super
          end

          # As it is possible to exceed 60% via exchange we allow them to be kept
          def can_hold_above_corp_limit?(_entity)
            true
          end

          def process_buy_shares(action)
            return super unless action.entity.company?

            company = action.entity
            bundle = action.bundle
            unless can_exchange?(company, bundle)
              raise GameError, "Cannot exchange #{action.entity.id} for #{bundle.corporation.id}"
            end

            bundle.share_price = 0
            buy_shares(company.owner, bundle, exchange: company)
            company.close!

            # Exchange is treated as a Buy, and no more actions allowed as Sell-Buy
            track_action(action, bundle.corporation)
          end

          def buyable_items(entity)
            items = []

            if @game.coal_railway_exchangable?
              @game.companies.select { |c| @game.coal_railway?(c) && c.owner == entity }.each do |c|
                items << Item.new(description: c.id, cost: 0)
              end
            end

            items << Item.new(description: nil, cost: @game.player_debt(entity)) if @game.player_debt(entity).positive?

            items
          end

          def buy_shares(entity, shares, exchange: nil, swap: nil, allow_president_change: true, borrow_from: nil, silent: nil)
            corporation = shares&.corporation
            president_share = corporation&.shares&.find(&:president)
            was_receivership = corporation.receivership?
            if president_share
              # When president's share is reserved we should not
              # allow presidency change
              allow_president_change = false if president_share.buyable == false

              if corporation&.floated? && corporation&.receivership? && entity.shares_of(corporation).any?
                # This is to cover for the case where this player
                # becomes president by buying a 2nd 10% share
                # when the corporation is in receivership. President share
                # has not yet been assigned to any player.
                allow_president_change = true
                president_share.buyable = true
              end
            end
            super(entity,
                  shares,
                  exchange: exchange,
                  swap: swap,
                  allow_president_change: allow_president_change,
                  borrow_from: borrow_from,
                  silent: silent)
            return if !president_share || !was_receivership || corporation.receivership? || president_share.owner == entity

            # Player has now taken control of this staatsbahn, but have not yet received precidency share.
            # So we swap 2 shares for the president share
            @game.share_pool.change_president(president_share, president_share.owner, entity)
          end

          def item_str(item)
            if item.cost.positive?
              "Repay debt of #{@game.format_currency(item.cost)}"
            else
              company = @game.company_by_id(item.description)
              regional = @game.associated_regional_railway(@game.company_by_id(item.description))
              "Exchange #{company.name} for #{regional.name} presidency"
            end
          end

          def process_special_buy(action)
            if action.item.cost.positive?
              repay_loan(action)
            else
              exchange_coal_company(action)
            end
          end

          private

          def repay_loan(action)
            player = action.entity
            debt = action.item.cost

            player.spend(debt, @game.bank)
            @game.reset_player_debt(player)

            @log << "#{player.name} pays off #{@game.format_currency(debt)}"
          end

          def exchange_coal_company(action)
            company = @game.company_by_id(action.item.description)
            regional = @game.exchange_coal_railway(company)

            # Exchange is treated as a Buy, and no more actions allowed as Sell-Buy
            track_action(action, regional)
          end

          def exchangable_ability(entity)
            return if !entity.company? || !@game.mountain_railway?(entity) || !@game.mountain_railway_exchangable?

            @game.abilities(entity, :exchange)
          end
        end
      end
    end
  end
end
