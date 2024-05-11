# frozen_string_literal: true

require_relative '../../../step/exchange'
require_relative 'minor_exchange'

module Engine
  module Game
    module G18Ardennes
      module Step
        class Exchange < Engine::Step::Exchange
          include MinorExchange

          def round_state
            super.merge(
              {
                major: nil,
                minor: nil,
                optional_trains: [],
                corporations_removing_tokens: nil,
                optional_forts: [],
              }
            )
          end

          def bought?
            @round.current_actions.any? do |action|
              Engine::Step::BuySellParShares::PURCHASE_ACTIONS.include?(action.class)
            end
          end

          def can_exchange?(entity, _bundle = nil)
            return false unless entity.corporation?
            return false unless entity.type == :minor

            @round.stock? ? !bought? : !@round.converted.nil?
          end

          def process_buy_shares(action)
            unless can_exchange?(action.entity, action.bundle)
              raise GameError, "Cannot exchange #{action.entity.id} for " \
                               "#{action.bundle.corporation.id}"
            end

            @round.minor = action.entity
            @round.major = action.bundle.shares.first.corporation
            exchange_minor(action.entity, action.bundle, true)
            @round.current_actions << action if @round.is_a?(Round::Stock)
          end
        end
      end
    end
  end
end
