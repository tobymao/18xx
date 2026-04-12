# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18OE
      module Step
        class Consolidate < Engine::Step::Base
          ACTIONS = %w[pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if pending_corps(entity).empty?

            ACTIONS
          end

          def description
            'Consolidate or abandon minors/regionals'
          end

          def pass_description
            'Pass (Consolidation TBD)'
          end

          def blocks?
            !pending_corps(current_entity).empty?
          end

          def process_pass(_action)
            corps = pending_corps(current_entity).map(&:name).join(', ')
            @log << "#{current_entity.name} passes consolidation — pending: #{corps} (merge/abandon TBD)"
            pass!
          end

          private

          def pending_corps(entity)
            entity.shares.map(&:corporation)
                  .select { |c| %i[minor regional].include?(c.type) }
                  .uniq
          end
        end
      end
    end
  end
end
