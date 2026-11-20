# frozen_string_literal: true

require_relative '../../g_1850/step/price_protection'

module Engine
  module Game
    module G1832
      module Step
        class MergerPriceProtection < G1850::Step::PriceProtection
          def active_entities
            return [] if takeover_pending?

            super
          end

          def skip!
            super unless takeover_pending?
          end

          private

          def takeover_pending?
            @round.respond_to?(:pending_takeover) && @round.pending_takeover
          end
        end
      end
    end
  end
end
