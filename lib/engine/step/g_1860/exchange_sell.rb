# frozen_string_literal: true

require_relative '../base'
require_relative '../share_buying'

module Engine
  module Step
    module G1860
      class ExchangeSell < Base
        include ShareBuying

        SELL_ACTIONS = %w[sell_company].freeze
        EXCHANGE_ACTIONS = %w[buy_shares].freeze

        def actions(entity)
          actions = []
          actions.concat(EXCHANGE_ACTIONS) if can_exchange?(entity)
          actions.concat(SELL_ACTIONS) if can_sell?(entity)
          actions
        end

        def blocks?
          false
        end

        def process_buy_shares(action)
          company = action.entity
          bundle = action.bundle
          unless can_exchange?(company, bundle)
            @game.game_error("Cannot exchange #{action.entity.id} for #{bundle.corporation.id}")
          end

          bundle.corporation.shares.each { |share| share.buyable = true }

          buy_shares(company.owner, bundle, exchange: company)
          company.close!
        end

        def can_buy?(entity, bundle)
          can_gain?(entity, bundle, exchange: true)
        end

        def process_sell_company(action)
          company = action.entity
          player = action.entity.owner
          @game.game_error("Cannot sell #{action.company.id}") unless can_sell?(company)

          sell_company(player, company, action.price)
          @round.last_to_act = player
        end

        def buy_price(entity)
          return 0 unless can_sell?(entity)

          entity.value - entity.abilities(:sell_to_bank).cost
        end

        private

        def can_exchange?(entity, bundle = nil)
          return false unless entity.company?
          return false unless (ability = entity.abilities(:exchange))

          owner = entity.owner
          return can_gain?(owner, bundle, exchange: true) if bundle

          corporation = @game.corporation_by_id(ability.corporation)
          return false unless corporation.ipoed

          shares = []
          shares << corporation.available_share if ability.from.include?(:ipo)
          shares << @game.share_pool.shares_by_corporation[corporation]&.first if ability.from.include?(:market)

          shares.any? { |s| can_gain?(entity.owner, s&.to_bundle, exchange: true) }
        end

        def can_sell?(entity)
          return false unless entity.company?
          return false if entity.owner == @game.bank
          return false unless @game.turn > 1

          !!entity.abilities(:sell_to_bank)
        end

        def sell_company(player, company, price)
          company.owner = @game.bank
          player.companies.delete(company)
          @game.bank.spend(price, player) if price.positive?
          @log << "#{player.name} sells #{company.name} to bank for #{@game.format_currency(price)}"
        end
      end
    end
  end
end
