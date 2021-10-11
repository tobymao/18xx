# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G1870
      module Step
        class Assign < Engine::Step::Assign
          def available_hex(entity, hex)
            if entity == @game.port_company
              assigned_hexes = @game.hexes.select { |h| h.assigned?(entity.id) }

              return assigned_hexes.include?(hex) unless assigned_hexes.empty?
            end

            super
          end

          def process_assign(action)
            entity = action.entity
            hex = action.target

            if hex.assigned?(entity.id) && entity == @game.port_company
              hex.remove_assignment!('GSC')
              hex.assign!('GSCᶜ', entity.owner)

              entity.owner.remove_assignment!('GSC')
              entity.owner.assign!('GSCᶜ')
              entity.close!

              @log << 'The port is now closed'
            else
              super
              @log << 'The port is open. To close the port use the ability again' if entity == @game.port_company
            end
          end
        end
      end
    end
  end
end
