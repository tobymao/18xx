# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G1840
      module Round
        class Acquisition < Engine::Round::Merger
          attr_reader :entities

          def self.short_name
            'CR'
          end

          def name
            'Company Round'
          end

          def offer
            @game.tram_corporations
          end

          def select_entities
            @game.operating_order.select { |item| item.type == :major }
          end
        end
      end
    end
  end
end
