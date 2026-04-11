# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1835
      module Step
        class MergeToPrussian < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

          # round_state is initialized once when the round is created and persists
          # for the entire round. DO NOT reset merge_players or merge_processed in
          # setup — setup is called at the start of each entity's turn, which would
          # re-offer the merge option every turn.
          def round_state
            {
              non_paying_shares: Hash.new { |h, k| h[k] = Hash.new(0) },
              merge_players: nil,
              merge_processed: {},
            }
          end

          def setup
            # Intentionally empty: merge state lives in round_state and must not
            # be reset each time a new company/player starts their turn.
          end

          def actions(entity)
            return [] unless @game.pr_formed
            return [] unless @game.mergers_allowed?
            return [] unless can_merge?(entity)

            # If mandatory (after 5-train), only allow 'choose' (no pass)
            @game.mergers_mandatory ? %w[choose] : ACTIONS
          end

          def active?
            return false unless @game.pr_formed
            return false unless @game.mergers_allowed?

            !current_merging_player.nil?
          end

          def blocking?
            active?
          end

          def description
            'Merge into Prussian Railroad'
          end

          def pass_description
            'Decline to merge'
          end

          def current_entity
            return nil unless active?

            current_merging_player
          end

          def active_entities
            return [] unless active?

            player = current_merging_player
            return [] unless player

            [player]
          end

          def current_merging_player
            @round.merge_players ||= @game.merger_player_order
            return nil if @round.merge_players.empty?

            @round.merge_players.each do |player|
              return player if player_has_mergeable_entities?(player)
            end

            nil
          end

          def player_has_mergeable_entities?(player)
            entities_for_player(player).any? { |e| !@round.merge_processed[entity_key(e)] }
          end

          def entities_for_player(player)
            mergeable_entities.select { |e| e.owner == player }
          end

          def can_merge?(entity)
            player = current_merging_player
            return false unless player
            return false unless entity == player

            player_has_mergeable_entities?(player)
          end

          def mergeable_entities
            @game.mergeable_pre_prussian_entities
          end

          def entity_key(entity)
            entity.respond_to?(:sym) ? entity.sym : entity.id
          end

          def choice_available?(entity)
            can_merge?(entity)
          end

          # Stock round view calls ipo_type unconditionally on the active step.
          # Return nil so render_pre_ipo renders nothing for this step.
          def ipo_type(_entity) end

          def choice_name
            'Merge entities into PR'
          end

          def choices
            player = current_merging_player
            return {} unless player

            entities = entities_for_player(player).reject { |e| @round.merge_processed[entity_key(e)] }
            entities.to_h do |entity|
              name = entity.name
              [entity_key(entity), "Merge #{name} into PR"]
            end
          end

          def process_choose(action)
            entity = action.entity
            player = current_merging_player
            raise GameError, 'Not your turn to merge' unless entity == player

            choice = action.choice
            target = find_entity_by_key(choice)
            raise GameError, "Cannot find entity: #{choice}" unless target
            raise GameError, "#{target.name} is not owned by you" unless target.owner == player
            raise GameError, "#{target.name} has already been processed" if @round.merge_processed[entity_key(target)]

            # Determine if this entity has operated this OR
            operated = @game.respond_to?(:operated_this_round?) && target.respond_to?(:operating_history) &&
                       @game.operated_this_round?(target)

            @game.merge_entity_to_prussian!(target, operated_this_or: operated)
            @round.merge_processed[entity_key(target)] = true

            # Check if player has more entities to merge; if not, move to next player
            advance_to_next_player unless player_has_mergeable_entities?(player)
          end

          def process_pass(action)
            raise GameError, 'Mergers are mandatory' if @game.mergers_mandatory

            player = action.entity
            @log << "#{player.name} declines to merge remaining companies into PR"

            # Mark all this player's entities as processed (declined)
            entities_for_player(player).each do |entity|
              @round.merge_processed[entity_key(entity)] = true
            end

            advance_to_next_player
          end

          def advance_to_next_player
            @round.merge_players ||= @game.merger_player_order

            # Remove the front of the queue until we find a player with unprocessed entities
            @round.merge_players.shift while @round.merge_players.any? &&
              !player_has_mergeable_entities?(@round.merge_players.first)

            # If no more players, this step is done
            pass! unless current_merging_player
          end

          def find_entity_by_key(key)
            @game.minors.find { |m| m.id == key } ||
              @game.companies.find { |c| c.id == key || c.sym == key }
          end
        end
      end
    end
  end
end
