# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1835
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          # OBB and PF tile-lay buttons are shown throughout the corporation's
          # operating turn (SpecialTrack sits before Track in the step list).
          # The player clicks whenever they want; no forced pass required.

          def description
            @company ? "Lay Track for #{@company.name}" : 'Lay Extra Track'
          end

          # Avoid @game.current_entity for player-owned companies (OBB, PF) — it
          # goes through active_step → blocking? → here (recursion risk).
          # Use @round.current_operator directly; it's set at the start of each OR turn.
          def hex_neighbors(entity, hex)
            return unless (ability = abilities(entity))
            return if !ability.hexes&.empty? && !ability.hexes&.include?(hex.id)

            if ability.type == :tile_lay && ability.reachable
              operator = entity.owner.corporation? ? entity.owner : @round.current_operator
              return unless @game.graph.connected_hexes(operator)[hex]
            end

            @game.hex_by_id(hex.id).neighbors.keys
          end

          def process_lay_tile(action)
            ability = abilities(action.entity)

            # OBB and PF teleport tile lays are EXTRA actions — they must NOT
            # consume a tile lay from the operating corporation's allotment.
            # lay_tile (not lay_tile_action) avoids incrementing num_laid_track.
            return super unless ability&.type == :teleport

            owner = if !action.entity.owner
                      nil
                    elsif action.entity.owner.corporation?
                      action.entity.owner
                    else
                      @round.current_operator
                    end

            lay_tile(action, spender: owner)
            @round.laid_hexes << action.hex
            ability.use!(upgrade: %i[green brown gray].include?(action.tile.color))

            if owner&.corporation? &&
               (operating_info = owner.operating_history[[@game.turn, @round.round_num]])
              operating_info.laid_hexes = @round.laid_hexes
            end

            # PF has a token ability: set up post-teleport token placement.
            # OBB has no token ability: skip this block entirely.
            return unless ability.owner.abilities.any? { |ab| ab.type == :token }

            company = ability.owner
            tokener = company.owner
            tokener = @round.current_operator if tokener.player?

            already_pending = @round.pending_tokens.any? do |pt|
              pt[:entity] == tokener && pt[:hexes].include?(action.hex)
            end
            return if already_pending

            if tokener.tokens_by_type.empty?
              company.remove_ability(ability)
            else
              @round.teleported = company
              @round.teleport_tokener = tokener
            end
          end
        end
      end
    end
  end
end
