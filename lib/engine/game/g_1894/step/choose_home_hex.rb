# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1894
      module Step
        class ChooseHomeHex < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def actions(entity)
            return [] unless entity == current_entity
            puts @game.pending_late_corporation.inspect
            puts 'a'
            return [] if @game.pending_late_corporation == nil
            puts 'b'

            ACTIONS
          end

          def choice_name
            return "Choose for #{@company.name}" if @company

            'Choose'
          end

          def choices
            hexes = @game.hexes.map { |h| h.id.to_s }
            puts hexes.inspect
            return hexes

            {}
          end

          def description
            'Choose'
          end

          def process_choose(action)
            puts action.choice.inspect
            @game.log << "XYZ chooses #{action.choice} as its home location"

            skip!
            @game.pending_late_corporation = nil
          end

          def skip!
            pass!
          end

          def choice_available?(entity)
            true
          end

          def find_corporation(entity)
            # Check all newly acquired companies if they have any choices
            @corporation = @round.acquired_companies.find do |c|
              entity == c.owner && !@game.company_choices(c, :special_choose).empty?
            end
            @company
          end

          def ipo_type(_entity) end
        end
      end
    end
  end
end
