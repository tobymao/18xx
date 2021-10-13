# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1822
      module Step
        class SpecialChoose < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless find_company(entity)

            ACTIONS
          end

          def choice_name
            return "Choose for #{@company.name}" if @company

            'Choose'
          end

          def choices
            return @game.company_choices(@company, :special_choose) if @company

            {}
          end

          def description
            'Choose'
          end

          def process_choose(action)
            @game.company_made_choice(@company, action.choice, :special_choose)
            @company = nil
          end

          def skip!
            pass!
          end

          def find_company(entity)
            # Check all newly acquired companies if they have any choices
            @company = @round.acquired_companies.find do |c|
              entity == c.owner && !@game.company_choices(c, :special_choose).empty?
            end
            @company
          end
        end
      end
    end
  end
end
