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

        # Temporary stub: 1867's #setup expects a national-type corporation
        # and hidden company '3' that this skeleton doesn't have yet.
        # Task 3 replaces this with the real #setup (16 minors, 8 majors,
        # the Union Pacific).
        def setup
          @interest = {}
          @national_reservations = []
          @show_majors = false
          @future_corporations = []
        end
      end
    end
  end
end
