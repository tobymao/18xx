# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1844
      module Step
        class DestinationCheck < Engine::Step::Base
          ACTIONS = %w[pass].freeze

          def actions(entity)
            return [] unless entity == current_entity

            ACTIONS
          end

          def auto_actions(entity)
            [Engine::Action::Pass.new(entity)]
          end

          def log_pass(entity); end
        end
      end
    end
  end
end
