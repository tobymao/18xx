# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1822
      module Step
        class Choose < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

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
            return @game.company_choices(@company, :choose) if @company

            {}
          end

          def description
            'Choose'
          end

          def process_choose(action)
            @game.company_made_choice(@company, action.choice, :choose)
            @company = nil
            pass!
          end

          def skip!
            pass!
          end

          def find_company(entity)
            @company = @game.company_by_id(@game.class::COMPANY_MGNR)
            return nil if !@company || @company&.owner != entity

            @company
          end
        end
      end
    end
  end
end
