# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18SJ
      module Step
        class Requisition < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def setup
            @choices = nil
          end

          def actions(entity)
            return [] unless entity == current_entity
            return [] if @game.requisition_turn == @game.turn || choices.empty?

            ACTIONS
          end

          def help
            "Select corporation that #{@game.edelsward.name} will start and requisit 100% of"
          end

          def choice_name
            'Select unparred corporation'
          end

          def choices
            return @choices if @choices

            @choices = {}
            @game.corporations
              .reject(&:closed?)
              .reject(&:minor?)
              .reject(&:share_price)
              .each do |c|
                @choices[c.name] = c.full_name
              end
            @choices
          end

          def description
            "Select #{@game.edelsward.name}'s next corporation"
          end

          def process_choose(action)
            @game.requisit_corporation(action.choice)
            @game.requisition_turn = @game.turn
            pass!
          end

          def skip!
            pass!
          end
        end
      end
    end
  end
end
