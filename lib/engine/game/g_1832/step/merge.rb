# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1832
      module Step
        class Merge < Engine::Step::Base
          ACTIONS_NO_PENDING = %w[merge pass].freeze
          ACTIONS_PENDING    = %w[choose pass].freeze

          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity

            if @round.merging
              return ACTIONS_PENDING if @round.merging[:initiator] == entity

              return []
            end

            return [] unless mergeable_corporations(entity).any?

            ACTIONS_NO_PENDING
          end

          def description
            @round.merging ? 'Choose Merger Type' : 'Merge or Take Over Another Corporation'
          end

          def choice_name
            'Merger Type'
          end

          def choices
            return {} unless @round.merging

            initiator = @round.merging[:initiator]
            target    = @round.merging[:target]
            c = {}

            if !@game.system?(initiator) && @game.can_form_system?(initiator, target)
              @game.available_systems.each do |sys|
                c["system_#{sys.id}"] = "System Formation \u2192 #{sys.name}"
              end
            end

            c['takeover'] = "Takeover #{target.name}" if @game.can_afford_takeover?(initiator, target)
            c
          end

          def process_merge(action)
            initiator = action.entity
            target    = action.corporation

            raise GameError, 'There is already a pending merger' if @round.merging

            unless mergeable_corporations(initiator).include?(target)
              raise GameError, "#{target.name} is not eligible to merge with #{initiator.name}"
            end

            @round.merging = { initiator: initiator, target: target }
          end

          def process_choose(action)
            raise GameError, 'No pending merger' unless @round.merging

            initiator = @round.merging[:initiator]
            target    = @round.merging[:target]
            choice    = action.choice

            if choice.start_with?('system_')
              system_id = choice.sub('system_', '')
              system = @game.corporation_by_id(system_id)
              raise GameError, "System #{system_id} is not available" unless @game.available_systems.include?(system)

              @game.perform_system_formation(initiator, target, system)
              @round.post_merge_entity = system
            elsif choice == 'takeover'
              if initiator.cash + initiator.owner.cash >= @game.takeover_cost(target)
                @game.perform_takeover(initiator, target)
                @round.post_merge_entity = initiator
              else
                # President needs to sell shares; SellSharesForTakeover step takes over
                @round.pending_takeover = { buyer: initiator, target: target }
              end
            else
              raise GameError, 'Invalid merger choice'
            end

            @round.merging = nil
            pass!
          end

          def process_pass(action)
            @round.merging = nil
            log_pass(action.entity)
            pass!
          end

          def merge_name(_entity = nil)
            'Merge or Takeover'
          end

          def show_other_players
            true
          end

          def mergeable_type(_entity)
            'Corporations eligible for merger or takeover'
          end

          def mergeable(entity)
            mergeable_corporations(entity)
          end

          def mergeable_corporations(corp)
            return [] unless corp.floated?
            return [] unless corp.operated?

            @game.corporations.select do |c|
              next false if c == corp
              next false if c.type == :system
              next false unless c.floated?
              next false unless c.operated?
              next false unless @game.corps_connected?(corp, c)

              (!@game.system?(corp) && @game.can_form_system?(corp, c)) || @game.can_afford_takeover?(corp, c)
            end
          end

          def sellable_bundles(_player, _corporation)
            []
          end

          def round_state
            { merging: nil, post_merge_entity: nil, pending_takeover: nil }
          end
        end
      end
    end
  end
end
