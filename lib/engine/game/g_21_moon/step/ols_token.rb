# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G21Moon
      module Step
        class OLSToken < Engine::Step::HomeToken
          def description
            'Place Old Landing Site Token'
          end

          def visible?
            true
          end

          def players_visible?
            true
          end

          def available
            []
          end

          def show_map
            true
          end

          def token_cost_override(_entity, _cith_hex, _slot, _token)
            0
          end

          def context_entities
            [pending_entity]
          end

          def active_context_entity
            pending_entity
          end
        end
      end
    end
  end
end
