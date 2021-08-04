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
            @game.tram_corporations.sort_by { |item| item.id.to_i }
          end

          def select_entities
            @game.operating_order.select { |item| item.type == :major && @game.corporate_card_minors(item).size < 3 }
          end
        end
      end
    end
  end
end
