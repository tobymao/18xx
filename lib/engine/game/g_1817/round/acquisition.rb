# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G1817
      module Round
        class Acquisition < Engine::Round::Merger
          attr_accessor :offering, :cash_crisis_player

          def self.short_name
            'AR'
          end

          def self.round_name
            'Acquisition Round'
          end

          def context_entities
            @offering
          end

          def active_context_entity
            @offering.first
          end

          def select_entities
            # Things that are offered up for acquisition, sale etc
            @offering = @game
                          .corporations
                          .select(&:floated?)
                          .sort.reverse
            @game.players.reject { |p| p.presidencies.empty? }
          end

          attr_reader :entities
        end
      end
    end
  end
end
