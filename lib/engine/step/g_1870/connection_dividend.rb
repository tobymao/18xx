# frozen_string_literal: true

require_relative '../dividend'

module Engine
  module Step
    module G1870
      class ConnectionDividend < Dividend
        DIVIDEND_TYPES = %i[payout withhold].freeze

        def share_price_change(_entity, revenue)
          return { share_direction: :right, share_times: 1 } if revenue.positive?

          {}
        end

        def active?
          @round.connection_runs.any?
        end

        def override_entities
          @round.connection_runs
        end

        def context_entities
          @round.entities
        end

        def active_context_entity
          @round.entities[@round.entity_index]
        end
      end
    end
  end
end
