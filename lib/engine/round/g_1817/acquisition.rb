# frozen_string_literal: true

require_relative '../merger'

module Engine
  module Round
    module G1817
      class Acquisition < Round::Merger
        attr_accessor :offering
        attr_accessor :cash_crisis_player

        def self.short_name
          'AR'
        end

        def name
          'Acquisition Round'
        end

        def select_entities
          # Things that are offered up for acquisition, sale etc
          @offering =  @game
                      .corporations
                      .select do |corp|
                        corp.floated? && !corp.share_price.acquisition? || @game.stock_prices_start_merger[corp].acquisition?
                      end
                      .sort.reverse
                      .select do |corp|
                        !corp.share_price.acquisition? || @game.stock_prices_start_merger[corp].acquisition?
                      end
          @game.players.select { |p| p.presidencies.any? }
        end

        attr_reader :entities
      end
    end
  end
end
