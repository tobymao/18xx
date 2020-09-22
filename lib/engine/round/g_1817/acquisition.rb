# frozen_string_literal: true

require_relative '../merger'

module Engine
  module Round
    module G1817
      class Acquisition < Round::Merger
        attr_accessor :offering
        def name
          'Acquisition Round'
        end

        def select_entities
          # Things that are offered up for acquisition, sale etc
          @offering =  @game
                      .corporations
                      .select(&:floated?)
                      .sort.reverse
          @game.players.select { |p| p.presidencies.any? }
        end

        attr_reader :entities
      end
    end
  end
end
