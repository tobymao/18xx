# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        class Assign < Engine::Step::Assign
          def available_hex(entity, hex)
            return unless entity.company?
            return unless entity.owner&.corporation?
            return if entity == @game.corn && entity.owner.tokens.none? { |token| token&.city&.hex == hex }
            return if entity == @game.hole && hex.tile.label.to_s != 'R'
            return if hex.assigned?(entity.id)

            @game.hex_by_id(hex.id).neighbors.keys
          end

          def description
            "Select hex for #{@company.name}"
          end

          def active_entities
            @company ? [@company] : super
          end

          def blocks?
            @company
          end

          def process_assign(action)
            entity = action.entity
            target = action.target

            super

            @game.assign_hole(entity, target) if entity == @game.hole

            @company = entity == @game.hole && !entity.all_abilities.empty? ? entity : nil
            return if @company

            @log << "#{entity.name} closes"
            entity.close!
          end
        end
      end
    end
  end
end
