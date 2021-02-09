# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G1822
      class Token < Token
        def available_tokens(entity)
          entity.tokens_by_type.reject { |t| t.type == :destination }
        end
      end
    end
  end
end
