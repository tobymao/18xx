# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Round
    module G18OE
      class Consolidation < Engine::Round::Stock
        def self.short_name
          'C'
        end

        def name
          'Consolidation Round'
        end
      end
    end
  end
end
