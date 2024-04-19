# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Ardennes
      module Step
        class DeclineForts < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if forts.empty?

            ACTIONS
          end

          def description
            'Keep or decline fort tokens'
          end

          def active?
            !forts.empty?
          end

          def active_entities
            [major]
          end

          def choice_available?(_entity)
            true
          end

          def choice_name
            "Minor #{minor.id} had #{forts.size} fort " \
              "#{forts.one? ? 'token' : 'tokens'}. " \
              'Choose how many of these fort tokens should be kept by ' \
              "#{major.id} (declined fort tokens are removed " \
              'from the game)'
          end

          def choices
            (0..forts.size).to_h { |i| [i, "#{i} fort#{i == 1 ? '' : 's'}"] }
          end

          def visible_corporations
            [major]
          end

          def process_choose(action)
            declined = forts.size - action.choice
            if declined.zero?
              @game.log << "#{major.id} keeps all of minor #{minor.id}’s " \
                           'fort tokens.'
            else
              @game.log << "#{major.id} discards #{declined} fort " \
                           "#{declined == 1 ? 'token' : 'tokens'}."
              forts.take(declined).each do |fort|
                major.remove_assignment!(fort)
              end
            end
            @round.optional_forts.clear
          end

          def log_skip(_entity); end

          private

          def major
            @round.major
          end

          def minor
            @round.minor
          end

          def forts
            @round.optional_forts
          end
        end
      end
    end
  end
end
