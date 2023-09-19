# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18NL
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def available_hex(entity, hex)
            # P2 cannot be used to token any hex with track on it
            return false unless hex.tile.paths.empty?
            # P2 cannot be used to token any hex currently blocked by a private company
            return false if hex.tile.blockers.any? { |c| !c.closed? && !c.owned_by_corporation? }

            super
          end
        end
      end
    end
  end
end
