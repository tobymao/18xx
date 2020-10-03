# frozen_string_literal: true

require_relative '../token'
require_relative 'only_one_token_per_round'

module Engine
  module Step
    module G18GA
      class Token < Token
        PASS_ONLY = %w[pass].freeze

        def actions(entity)
          return [] if already_tokened_this_round?(entity) || entity.company?
          return ACTIONS if can_place_token?(entity)
          return PASS_ONLY if remaining_token_ability?(entity)

          []
        end

        def adjust_token_price_ability!(entity, token, hex)
          return [token, nil] if @game.active_step.current_entity.corporation?

          super
        end

        include OnlyOneTokenPerRound
      end
    end
  end
end
