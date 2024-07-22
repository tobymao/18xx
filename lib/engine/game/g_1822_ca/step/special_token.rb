# frozen_string_literal: true

require_relative '../../g_1822/step/special_token'

module Engine
  module Game
    module G1822CA
      module Step
        class SpecialToken < G1822::Step::SpecialToken
          def actions(entity)
            if entity.id == @game.class::COMPANY_WINNIPEG_TOKEN &&
               entity.owner == current_entity &&
               !available_tokens(entity).empty? &&
               ability(entity)
              ['place_token']
            else
              []
            end
          end

          def available_tokens(entity)
            if entity.id == @game.class::COMPANY_WINNIPEG_TOKEN && @game.exchange_tokens(entity.owner).positive?
              [Engine::Token.new(entity.owner)]
            else
              []
            end
          end

          def process_place_token(action)
            entity = action.entity.owner

            if (city = action.city).tokened_by?(entity)
              raise GameError,
                    "#{entity.name} already has a token in #{city.hex.location_name} (#{city.hex.id}) city #{city.index}"
            end

            super

            @game.remove_exchange_token(entity)
          end
        end
      end
    end
  end
end
