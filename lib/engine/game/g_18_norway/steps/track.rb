# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Norway
      module Step
        class Track < Engine::Step::Track
          def setup
            @round.mountain_hex = nil
          end

          def destination_node_check?(corporation)
            home_node = corporation.tokens.first.city
            @game.oslo.tile.nodes.each do |node|
              node.walk(corporation: corporation) do |path, _, _|
                return true if path.nodes.include?(home_node)
              end
            end
            false
          end

          def process_lay_tile(action)
            @round.mountain_hex = action.hex if @game.mountain?(action.hex)
            super

            corporation = action.entity
            ability = @game.abilities(corporation, :extra_tile_lay)
            return if ability.nil?
            return unless destination_node_check?(corporation)

            @log << "#{corporation.name} looses the ability to lay two tiles since it now is connected to Oslo"
            corporation.remove_ability(ability)
            pass!
          end

          def round_state
            super.merge({ mountain_hex: nil })
          end
        end
      end
    end
  end
end
