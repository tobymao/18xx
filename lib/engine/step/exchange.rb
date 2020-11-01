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
        unless can_exchange?(company, bundle)
          @game.game_error("Cannot exchange #{action.entity.id} for #{bundle.corporation.id}")
        end

        buy_shares(company.owner, bundle, exchange: company)
        company.close!
      end

      def can_buy?(entity, bundle)
        can_gain?(entity, bundle, exchange: true)
      end

      def can_exchange?(entity, bundle = nil)
        return false unless entity.company?
        return false unless (ability = entity.abilities(:exchange))

        owner = entity.owner
        return can_gain?(owner, bundle, exchange: true) if bundle

        corporations =
          ability.corporation == 'any' ? @game.corporations : [@game.corporation_by_id(ability.corporation)]

        shares = []
        corporations.each do |corporation|
          shares << corporation.available_share if ability.from.include?(:ipo)
          shares << @game.share_pool.shares_by_corporation[corporation]&.first if ability.from.include?(:market)
        end

        shares.any? { |s| can_gain?(entity.owner, s&.to_bundle, exchange: true) }
      end
    end
  end
end
