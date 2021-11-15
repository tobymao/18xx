# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18NY
      module Step
        class MergeChoice < Engine::Step::Base
          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity.corporation? && entity.type == :minor
            return [] unless connected?(entity)
            return [] if (@mandatory_merge = mandatory_merge?(entity))
            return [] unless owner_can_afford?(entity)
            return [] unless share_available?

            ['choose']
          end

          def description
            'Merge Into NYC'
          end

          def mandatory_merge?(entity)
            return true if @game.nyc_formation == :round_two
            return true if %w[1 2].include?(entity.id)

            false
          end

          def connected?(entity)
            @round.connected_minors.include?(entity)
          end

          def owner_can_afford?(entity)
            entity.owner.cash >= (@game.nyc_merger_cost(entity) * -1)
          end

          def share_available?
            @game.nyc_corporation.available_share || !share_pool.shares_of(@game.nyc_corporation).empty?
          end

          def choices
            ["Merge (#{@game.format_currency(@game.nyc_merge_cost(current_entity))})"]
          end

          def choice_name
            ''
          end

          def process_choose(action)
            @game.merge_into_nyc(action.entity)
          end

          def skip!
            super

            return unless @mandatory_merge

            @game.merge_into_nyc(current_entity)
            @mandatory_merge = nil
          end

          def log_skip(entity)
            return if @mandatory_merge

            str = "#{entity.name} cannot merge into NYC. "
            if !connected?(entity)
              str += "#{entity.name} is not connected"
            elsif !owner_can_afford?(entity)
              str += "#{entity.owner.name} cannot spend #{@game.format_currency(@game.nyc_merger_cost(entity) * -1)}"
            elsif !share_available?
              str += 'No NYC shares are available.'
            end

            @game.log << str
          end
        end
      end
    end
  end
end
