# frozen_string_literal: true

require_relative 'track'

module Engine
  module Game
    module G1822CA
      module Step
        class AcquisitionTrack < Track
          def description
            'Lay/Upgrade Track (Acquisition Bonus)'
          end

          def help
            "#{@round.acquiring_major.name} receives a bonus track action for acquiring a Minor."
          end

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity == @round.acquiring_major

            self.class::ACTIONS
          end

          # can lay or upgrade regardless of prior actions this turn
          def tile_lay_index
            0
          end

          def process_lay_tile(_action)
            super
            pass!
          end

          def log_skip(_entity); end
        end
      end
    end
  end
end
