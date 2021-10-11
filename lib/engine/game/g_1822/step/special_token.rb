# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G1822
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def actions(entity)
            return ['place_token'] if ability(entity) &&
              !available_tokens(entity).empty? &&
              @game.round.active_step.respond_to?(:process_place_token)

            []
          end

          def available_tokens(entity)
            if entity.id == @game.class::COMPANY_LCDR
              return @game.exchange_tokens(entity.owner).positive? ? [Engine::Token.new(entity.owner)] : []
            end

            super
          end

          def process_place_token(action)
            super
            return unless action.entity.id == @game.class::COMPANY_LCDR

            @game.remove_exchange_token(action.entity.owner)
            @log << "#{action.entity.name} closes"
            action.entity.close!
          end
        end
      end
    end
  end
end
