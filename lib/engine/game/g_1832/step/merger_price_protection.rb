# frozen_string_literal: true

require_relative '../../g_1850/step/price_protection'

module Engine
  module Game
    module G1832
      module Step
        class MergerPriceProtection < G1850::Step::PriceProtection
          def active_entities
            return [] if @round.respond_to?(:pending_takeover) && @round.pending_takeover

            super
          end
        end
      end
    end
  end
end
