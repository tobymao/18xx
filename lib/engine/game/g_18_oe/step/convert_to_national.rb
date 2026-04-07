# frozen_string_literal: true

require_relative '../../../../step/base'

module Engine
  module Game
    module G18OE
      module Step
        class ConvertToNational < Engine::Step::Base
          ACTIONS = %w[convert pass].freeze

          def actions(entity)
            return [] unless @game.nationals_forming?
            return [] unless entity == current_entity

            can_convert_any?(entity) ? ACTIONS : ['pass']
          end

          def current_entity
            @game.nationals_formation_queue&.first
          end

          def active_entities
            [current_entity].compact
          end

          def active?
            @game.nationals_forming?
          end

          def blocking?
            @game.nationals_forming?
          end

          def description
            'National Formation'
          end

          def pass_description
            'Pass (National Formation)'
          end

          def log_pass(entity)
            @log << "#{entity.name} passes national formation"
          end

          def can_convert_any?(player)
            convertible_majors(player).any?
          end

          def convertible_majors(player)
            @game.corporations.select { |c| c.owner == player && c.type == :major && c.floated? }
          end

          def process_convert(action)
            corporation = action.corporation
            raise GameError, "#{corporation.name} cannot convert to a national" unless corporation.type == :major

            @game.convert_to_national(corporation)
            @log << "#{action.entity.name} converts #{corporation.name} to a national"
          end

          def process_pass(action)
            log_pass(action.entity)
            @game.nationals_formation_queue.shift
            @game.nationals_can_form = false if @game.nationals_formation_queue.empty?
          end
        end
      end
    end
  end
end
