# frozen_string_literal: true

require_relative '../base'
require_relative '../share_buying'

module Engine
  module Step
    module G1860
      class Exchange < Base
        include ShareBuying

        EXCHANGE_ACTIONS = %w[buy_shares].freeze

        def actions(entity)
          actions = []
          actions.concat(EXCHANGE_ACTIONS) if can_exchange?(entity)
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
          @game.check_new_layer
        end

        def can_buy?(entity, bundle)
          can_gain?(entity, bundle, exchange: true)
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
      end
    end
  end
end
