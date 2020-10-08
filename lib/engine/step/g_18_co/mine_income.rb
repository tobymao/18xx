# frozen_string_literal: true

require_relative '../base'

module Engine
    module Step
        module G18CO
            class MineIncome < Base
                ACTIONS = %w[collect_mine_income].freeze

                def description
                    'Collect Mine Income'
                end

                def process_collect_mine_income(action)
                    @log << "#{entity.name} collects ??? mine income"
                end
            end
        end
    end
end
  