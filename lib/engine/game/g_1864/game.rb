# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../g_1867/game'

module Engine
  module Game
    module G1864
      class Game < G1867::Game
        include_meta(G1864::Meta)
        include Entities
        include Map

        GREEN_CORPORATIONS = %w[MB Y V TR SV E].freeze

        # Filled in by Task 4 with the Omaha and Cheyenne hex ids. Must be
        # defined here and empty: 1867's value is ['L12'], a hex that does not
        # exist on the 1864 map, and `setup` below dereferences it.
        NATIONAL_RESERVATIONS = [].freeze

        attr_reader :union_pacific, :future_corporations

        def setup
          @interest = {}
          @show_majors = false
          @national_reservations = self.class::NATIONAL_RESERVATIONS.dup

          @union_pacific = @national = @corporations.find { |c| c.type == :national }
          @corporations.delete(@national)
          @national.ipoed = true
          share_price = stock_market.market.flatten.compact.find { |sp| sp.price == 80 }
          stock_market.set_par(@national, share_price)

          @corporations, @future_corporations = @corporations.partition do |corporation|
            corporation.type == :minor && !self.class::GREEN_CORPORATIONS.include?(corporation.id)
          end
        end

        def all_corporations
          @corporations + [@national]
        end
      end
    end
  end
end
