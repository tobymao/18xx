# frozen_string_literal: true

require_relative '../../../round/base'

module Engine
  module Game
    module GRollingStock
      module Round
        class Acquisition < Engine::Round::Base
          attr_accessor :proposals, :transacted_cash, :transacted_companies

          def self.round_name
            'Acquisition Round'
          end

          def self.short_name
            'ACQ'
          end

          def name
            'Acquisition'
          end

          def unordered?
            true
          end

          def select_entities
            @game.acquisition_players
          end

          def finished?
            @game.finished || @entities.all?(&:passed?)
          end
        end
      end
    end
  end
end
