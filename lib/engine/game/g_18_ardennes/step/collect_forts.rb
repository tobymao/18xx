# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Ardennes
      module Step
        class CollectForts < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless forts_available?

            ACTIONS
          end

          def auto_actions(entity)
            return unless reachable_forts(entity).empty?

            [Engine::Action::Pass.new(entity)]
          end

          def description
            'Collect fort tokens'
          end

          def pass_description
            'Do not collect any fort tokens'
          end

          def choice_available?(_entity)
            true
          end

          def choice_name
            'Choose fort tokens to collect'
          end

          def choices
            reachable_forts(current_entity)
              .flat_map(&:tokens)
              .map(&:hex)
              .map(&:coordinates)
              .to_h { |coord| [coord, "Collect fort token on hex #{coord}"] }
          end

          # Checks whether there are any fort hexes with track. This does not
          # check whether the current corporation has a route to the hex, this
          # is to avoid computing the game graph whilst a game is being loaded.
          # Usually this will return false, except for immediately after a
          # yellow tile has been laid on a fort hex. Fort tokens are almost
          # always going to be collected as soon as this has happened.
          def forts_available?
            @game.fort_hexes.any? { |hex| hex.tile.color != :white }
          end

          # Hexes with fort tokens that this corporation has a route to.
          def reachable_forts(corporation)
            @game.fort_hexes.intersection(
              @game.graph_for_entity(corporation).reachable_hexes(corporation).keys
            )
          end

          def process_choose(action)
            collect_fort(@game.hex_by_id(action.choice), action.entity)
          end

          def collect_fort(hex, corporation)
            @game.log << "#{corporation.id} collects a fort token from hex " \
                         "#{hex.coordinates} (#{hex.location_name})"
            hex.tokens.first.remove!
            corporation.assign!(hex.coordinates)
            # Never check this hex again for forts if there are no tokens left.
            @game.fort_hexes.delete(hex) if hex.tokens.empty?
          end
        end
      end
    end
  end
end
