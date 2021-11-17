# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18NY
      module Step
        class MergeWithNYC < Engine::Step::Base
          ACTIONS = %w[merge pass].freeze

          def actions(entity)
            return [] unless entity == current_entity

            ACTIONS
          end

          def auto_actions(entity)
            actions = []

            if mandatory_merge?(entity)
              actions << Engine::Action::Merge.new(entity, corporation: entity)
            elsif !connected?(entity) || !owner_can_afford?(entity) || !share_available?
              actions << Engine::Action::Pass.new(entity)
            end

            actions
          end

          def description
            "#{merge_target.name} Merge Decision"
          end

          def pass_description
            'Decline'
          end

          def active_entities
            [mergee].compact
          end

          def blocking?
            !@minors.empty?
          end

          def override_entities
            @minors
          end

          def merge_name(_entity = nil)
            cost = @game.nyc_merger_cost(mergee)
            "Merge #{mergee.name} into #{merge_target.name} (#{@game.format_currency(cost)})"
          end

          def mergeable_type(corporation)
            "Corporations that can merge with #{corporation.name}"
          end

          def merge_target
            @game.nyc_corporation
          end

          def mergeable(_corporation)
            [mergee].compact
          end

          def show_other_players
            true
          end

          def mergee
            @minors&.first
          end

          def mandatory_merge?(entity)
            return true if @round.round_num == 2
            return true if %w[1 2].include?(entity.id)

            false
          end

          def connected?(entity)
            @connected_minors.include?(entity)
          end

          def owner_can_afford?(entity)
            entity.owner.cash >= (@game.nyc_merger_cost(entity) * -1)
          end

          def share_available?
            @game.nyc_corporation.available_share || !share_pool.shares_of(@game.nyc_corporation).empty?
          end

          def process_merge(action)
            entity = action.entity
            raise GameError, "Not #{entity.name}'s turn" if entity != @minors.first

            @game.log << "#{entity.name} is required to merge into #{merge_target.name}" if mandatory_merge?(entity)
            @game.merge_into_nyc(entity)
            
            @minors.shift
          end

          def process_pass(action)
            entity = action.entity
            if !connected?(entity)
              @game.log << "#{entity.name} is not connected to Albany and is not allowed to merge into #{merge_target.name}"
            elsif !owner_can_afford?(entity)
              @game.log << "#{entity.owner.name} cannot spend #{@game.format_currency(@game.nyc_merger_cost(entity) * -1)} " \
                           "required to merge #{entity.name} into #{merge_target.name}"
            elsif !share_available?
              @game.log << "No #{merge_target.name} shares are available for #{entity.name} to merge into #{merge_target.name}"
            end

            @minors.shift
          end

          def setup
            @minors = @game.active_minors
            @connected_minors = @game.minors_connected_to_albany
          end
        end
      end
    end
  end
end
