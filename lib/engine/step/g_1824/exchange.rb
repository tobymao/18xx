# frozen_string_literal: true

require_relative '../exchange'

module Engine
  module Step
    module G1824
      class Exchange < Exchange
        def process_buy_shares(action)
          player = action.entity.owner

          super

          @round.last_to_act = player
          @round.player_actions << action
        end

        def can_exchange?(entity, bundle = nil)
          return false unless exchangable_entity?(entity)
          return false unless (ability = @game.abilities(entity, :exchange))

          owner = entity.company? ? entity.owner : entity.player
          return can_gain?(owner, bundle, exchange: true) if bundle

          corporations = ability.corporation.map { |c| @game.corporation_by_id(c) }

          shares = []
          corporations.each do |corporation|
            shares << corporation.available_share if ability.from.include?(:ipo)
            shares << @game.share_pool.shares_by_corporation[corporation]&.first if ability.from.include?(:market)
          end

          shares.any? { |s| can_gain?(entity.owner, s&.to_bundle, exchange: true) }
        end

        private

        def exchangable_entity?(entity)
          if entity.corporation?
            return @game.coal_railway?(entity) && @game.phase.status.include?('may_exchange_coal_railways')
          end

          return false unless entity.company?

          @game.mountain_railway?(entity) && @game.phase.status.include?('may_exchange_mountain_railways')
        end
      end
    end
  end
end
