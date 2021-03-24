# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        class Assign < Engine::Step::Assign
          def available_hex(entity, hex)
            return unless entity.company?
            return unless entity.owner&.corporation?
            return unless entity.owner.tokens.map { |token| token&.city&.hex&.id }.include?(hex.id)
            return if hex.assigned?(entity.id)

            @game.hex_by_id(hex.id).neighbors.keys
          end

          def process_assign(action)
            entity = action.entity

            super

            @log << "#{entity.name} closes"
            entity.close!
          end
        end
      end
    end
  end
end
