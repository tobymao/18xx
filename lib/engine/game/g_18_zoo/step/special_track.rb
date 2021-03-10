# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        class SpecialTrack < Engine::Step::Track
          ACTIONS = %w[lay_tile].freeze

          def actions(entity)
            return [] if entity != current_entity || !can_lay_tile?(current_entity)

            ACTIONS
          end

          def description
            return 'Lay upgrade (Rabbits)' if rabbits_is_in_use?

            '???'
          end

          def active?
            rabbits_is_in_use?
          end

          def potential_tiles(_entity, hex)
            return super unless rabbits_is_in_use?

            @game.tiles
                 .uniq(&:name)
                 .select { |t| @game.upgrades_to?(hex.tile, t) }
                 .reject(&:blocks_lay)
          end

          def process_lay_tile(action)
            super

            # reset laid track for this or
            @round.num_laid_track = 0
            @round.upgraded_track = false
            @round.laid_hexes = []

            return unless @game.rabbits_in_use?

            # reset count to go back to previous action
            @game.rabbits.all_abilities[0].count_this_or = 0

            # use the power to reduce the count
            @game.rabbits.all_abilities[0].use!

            @game.rabbits.close! if @game.rabbits.all_abilities.empty?
          end

          def rabbits_is_in_use?
            @game.rabbits.all_abilities[0].count_this_or == 1
          end

          def get_tile_lay(entity)
            # TODO: handle @round.num_laid_track in some way

            super
          end

          def lay_tile_action(action, entity: nil, spender: nil)
            # TODO: handle @round.num_laid_track in some way

            super
          end

          def upgraded_track(action)
            # TODO: handle @round.num_laid_track in some way

            super
          end
        end
      end
    end
  end
end
