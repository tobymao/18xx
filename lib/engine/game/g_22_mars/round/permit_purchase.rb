# frozen_string_literal: true

module Engine
  module Game
    module G22Mars
      module Round
        class PermitPurchase < Engine::Round::Draft
          def self.short_name
            'PPR'
          end

          def name
            'Permit Purchase Round'
          end
        end
      end
    end
  end
end
