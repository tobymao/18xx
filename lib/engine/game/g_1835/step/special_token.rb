# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G1835
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          # NF and PB have player-owned token abilities (when: 'owning_player_or_turn').
          # The base ability() calls @game.abilities without a time filter, bypassing
          # G1835's ability_right_time? which blocks these during minor operation turns.
          # Pass the same timing array that SpecialTrack uses so the filter applies.
          POSSIBLE_ABILITY_TIMES = %w[
            %current_step%
            owning_corp_or_turn
            owning_player_or_turn
          ].freeze

          def actions(entity)
            # PB (PF) may not place its token until BA has placed its home token.
            if entity&.company? && entity.sym == 'PB'
              ba = @game.corporation_by_id('BA')
              return [] unless ba&.tokens&.any?(&:used)
            end

            super
          end

          def ability(entity)
            return unless entity&.company?

            @game.abilities(entity, :token, time: POSSIBLE_ABILITY_TIMES) do |ab, _|
              return ab
            end

            # Return a used teleport ability to trigger post-teleport token placement,
            # but only for companies that also have a token ability (e.g. PB/PF).
            # OBB only has a teleport and no token — don't intercept its second tile lay.
            if entity.all_abilities.any? { |a| a.type == :token }
              @game.abilities(entity, :teleport, time: POSSIBLE_ABILITY_TIMES) do |ab, _|
                return ab if ab.used?
              end
            end

            nil
          end

          # Override blocking? to avoid calling available_tokens (which leads to
          # token_owner → current_entity → active_step → blocking? → infinite recursion).
          # PF (PB) may not place its token until BA has already placed its home token.
          def blocking?
            return false unless @round.teleported

            ba = @game.corporation_by_id('BA')
            ba&.tokens&.any?(&:used)
          end

          # For player-owned companies (NF, PB) that can lay tokens, the token being placed comes from
          # the currently operating major corporation, not from the player.
          # We return exactly ONE token so that city_slot.rb takes the direct-placement
          # path (next_tokens.size == 1) rather than opening the TokenSelector.
          # TokenSelector hardcodes @game.current_entity as the action entity, which
          # would send entity=BY instead of entity=NF, causing Track to block.
          def available_tokens(entity)
            ab = ability(entity)
            return super unless ab
            return super if !%i[teleport token].include?(ab.type) || ab.from_owner
            return super unless entity.owner&.player?

            # Use @round.current_operator rather than @game.current_entity to avoid
            # infinite recursion: current_entity → active_step → blocking? → available_tokens
            first = @round.current_operator.tokens.reject(&:used).first
            first ? [first] : []
          end
        end
      end
    end
  end
end
