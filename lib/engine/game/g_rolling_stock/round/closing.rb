# frozen_string_literal: true

require_relative '../../../round/base'

module Engine
  module Game
    module GRollingStock
      module Round
        class Closing < Engine::Round::Base
          def self.round_name
            'Closing Round'
          end

          def self.short_name
            'CLO'
          end

          def name
            'Closing'
          end

          def unordered?
            true
          end

          def select_entities
            @game.closing_players
          end

          def finished?
            @game.finished || @entities.all?(&:passed?)
          end
        end
      end
    end
  end
end
