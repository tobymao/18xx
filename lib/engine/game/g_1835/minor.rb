# frozen_string_literal: true

require_relative '../../minor'

module Engine
  module Game
    module G1835
      class Minor < Engine::Minor
        attr_reader :value, :revenue

        def initialize(sym:, name:, abilities: [], **opts)
          @value = opts[:value]
          @revenue = opts[:revenue]
          super
          # Map tokens show the minor number (M1–M6) via a dedicated SVG.
          # Corporation @logo / @simple_logo are kept unchanged for charter display (PR logo).
          token_logo = "/logos/1835/#{sym}.svg"
          @tokens.each do |t|
            t.logo = token_logo
            t.simple_logo = token_logo
          end
        end
      end
    end
  end
end
