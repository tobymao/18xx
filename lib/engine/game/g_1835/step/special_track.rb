# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1835
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def actions(entity)
            if entity.company?
              return [] unless entity.owner == @round.current_entity&.owner

              ability = @game.abilities(entity, :tile_lay)
              return [] unless ability

              ['lay_tile']
            else
              super
            end
          end

          def active_entities
            companies = @game.companies.select do |c|
              c.owner == @round.current_entity&.owner && @game.abilities(c, :tile_lay)
            end
            companies.empty? ? super : companies
          end

          def can_process_action?(action)
            action.entity.company? && super
          end
        end
      end
    end
  end
end
