# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1835
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def active_entities
            entities = super
            companies = @game.companies.select do |c|
              c.owner == @round.current_entity&.owner && @game.abilities(c, :tile_lay)
            end
            combined = (entities + companies).uniq

            # HYPOTHESIS TEST LOGGING
            @game.log << "TEST LOG - active_entities: #{combined.map(&:name).join(', ')}" if companies.any?

            combined
          end

          def actions(entity)
            acts = super
            if entity.company? && entity.owner == @round.current_entity&.owner && @game.abilities(entity, :tile_lay)
              acts |= ['lay_tile']
            end

            # HYPOTHESIS TEST LOGGING
            @game.log << "TEST LOG - actions for #{entity.name}: #{acts.inspect}" if acts.include?('lay_tile')

            acts
          end

          def process_lay_tile(action)
            # HYPOTHESIS TEST LOGGING
            @game.log << "TEST LOG - process_lay_tile triggered by: #{action.entity.name}"

            super
          end
        end
      end
    end
  end
end
