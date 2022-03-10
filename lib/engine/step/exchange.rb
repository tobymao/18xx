# frozen_string_literal: true

require_relative 'base'
require_relative 'share_buying'

module Engine
  module Step
    class Exchange < Base
      include ShareBuying

      ACTIONS = %w[buy_shares].freeze

      def actions(entity)
        return ACTIONS if can_exchange?(entity)

        []
      end

      def blocks?
        false
      end

      def process_buy_shares(action)
        company = action.entity
        bundle = action.bundle
        raise GameError, "Cannot exchange #{action.entity.id} for #{bundle.corporation.id}" unless can_exchange?(company, bundle)

        buy_shares(company.owner, bundle, exchange: company)
        @round.players_history[company.owner][bundle.corporation] << action if @round.respond_to?(:players_history)
        company.close!
      end

      def can_buy?(entity, bundle)
        can_gain?(entity, bundle, exchange: true)
      end

      def can_exchange?(entity, bundle = nil)
        return false unless entity.company?
        return false unless (ability = @game.abilities(entity, :exchange))

        owner = entity.owner
        return can_gain?(owner, bundle, exchange: true) if bundle

        shares = []
        @game.exchange_corporations(ability).each do |corporation|
          shares << corporation.reserved_shares.first if ability.from.include?(:reserved)
          shares << corporation.available_share if ability.from.include?(:ipo)
          shares << @game.share_pool.shares_by_corporation[corporation]&.first if ability.from.include?(:market)
        end

        shares.compact.any? { |s| can_gain?(entity.owner, s&.to_bundle, exchange: true) }
      end
    end
  end
end
