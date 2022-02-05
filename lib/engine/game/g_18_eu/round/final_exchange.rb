# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18EU
      module Round
        class FinalExchange < Engine::Round::Stock
          def initialize(game, steps, **opts)
            super

            @entity_index = @game.players.index(@game.minor_exchange_priority)
            @game.minor_exchange = :in_progress
          end

          def self.short_name
            'FER'
          end

          def name
            'Minor Company Final Exchange Round'
          end

          def setup
            start_entity
          end

          def select_entities
            @game.players.reject(&:bankrupt)
          end

          def finished?
            super || @game.minors.empty? || @game.minor_exchange == :done
          end

          private

          def finish_round
            @game.minor_exchange = :done
            @entity_index = 0
          end
        end
      end
    end
  end
end
