# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1824
      module Step
        class BuySellParExchangeShares < Engine::Step::BuySellParShares
          EXCHANGE_ACTIONS = %w[buy_shares].freeze
          BUY_ACTION = %w[special_buy].freeze

          def actions(entity)
            return can_exchange?(entity) ? EXCHANGE_ACTIONS : [] if entity.company?

            actions = super
            actions << 'special_buy' if !actions.empty? && buyable_items(entity)
            actions
          end

          def can_buy?(entity, bundle)
            super && @game.buyable?(bundle.corporation)
          end

          def can_sell?(_entity, bundle)
            super && @game.buyable?(bundle.corporation)
          end

          def can_gain?(entity, bundle, exchange: false)
            return false if exchange && !@game.mountain_railway_exchangable? && !@game.coal_railway_exchangable?

            super && @game.buyable?(bundle.corporation)
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
            return [] unless @game.coal_railway_exchangable?

            @game.companies.select { |c| @game.coal_railway?(c) && c.owner == entity }.map do |c|
              Item.new(description: c.id, cost: 0)
            end
          end

          def item_str(item)
            company = @game.company_by_id(item.description)
            regional = @game.associated_regional_railway(@game.company_by_id(item.description))
            "Exchange #{company.name} for #{regional.name} presidency"
          end

          def process_special_buy(action)
            company = @game.company_by_id(action.item.description)
            regional = @game.exchange_coal_railway(company)

            # Exchange is treated as a Buy, and no more actions allowed as Sell-Buy
            track_action(action, regional)
          end

          private

          def exchangable_ability(entity)
            return if !entity.company? || !@game.mountain_railway?(entity) || !@game.mountain_railway_exchangable?

            @game.abilities(entity, :exchange)
          end
        end
      end
    end
  end
end
