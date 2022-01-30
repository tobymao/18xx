# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1866
      module Step
        class CloseCorporation < Engine::Step::Base
          def actions(_entity)
            []
          end

          def skip!
            pass!

            entity = current_entity
            return if !entity.corporation? || !@game.corporation?(entity) || entity.share_price&.type != :close

            @game.corporation_closes(entity)
          end
        end
      end
    end
  end
end
