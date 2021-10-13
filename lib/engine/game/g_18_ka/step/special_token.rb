# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18KA
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def actions(entity)
            return [] if entity.company? && entity.owner.player?

            super
          end

          def process_place_token(action)
            company = action.entity
            hex = action.city.hex
            case company.sym
            when 'C'
              raise GameError, "Must use #{company.name} ability on farm tile" unless hex.tile.labels.first.to_s == 'F'
            when 'G'
              raise GameError, "Must use #{company.name} ability on capitol tile" unless hex.tile.labels.first.to_s == 'C'
            when 'I'
              raise GameError, "Must use #{company.name} ability on space elevator tile" unless hex.tile.labels.first.to_s == 'SE'
            end

            super

            # The farm / captiol / space elevator privates close immediately on token ability use
            return unless %w[C G I].include?(company.sym)

            @game.log << "#{company.name} closes"
            company.close!
          end
        end
      end
    end
  end
end
