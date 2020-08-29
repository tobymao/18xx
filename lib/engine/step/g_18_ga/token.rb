# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G18GA
      class Token < Token
        def adjust_token_price_ability!(entity, token, hex)
          return [token, nil] if @game.active_step.current_entity.corporation?

          super
        end
      end
    end
  end
end
