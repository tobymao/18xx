# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1835
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def available_tokens(entity)
            return [] unless entity.corporation?

            entity.tokens_by_type
          end
        end
      end
    end
  end
end
