# frozen_string_literal: true

require_relative '../../../step/assign'
require_relative 'skip_abbreviated_round'

module Engine
  module Game
    module G18OE
      module Step
        class Assign < Engine::Step::Assign
          include SkipAbbreviatedRound

          def actions(entity)
            return [] unless entity.company?
            return [] if entity.owner != @round.current_operator

            super
          end

          def available_hex(entity, hex)
            return unless entity.company?
            return unless @game.abilities(entity, :assign_hexes)
            return unless @game.minor_d_city?(hex)

            hex.neighbors.keys
          end

          def process_assign(action)
            hex = action.target
            raise GameError, "#{hex.name} cannot hold Minor D's token" unless available_hex(action.entity, hex)

            @game.place_minor_d_token!(hex)
          end
        end
      end
    end
  end
end
