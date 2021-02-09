# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1856
      class Escrow < Base
        # Since *any* corporation could destinated after a given corporation does a tile lay, we need
        # to check for *all* corporations, and since multiple corporations could destinate at once
        # we need to be able to support multiple destinating at once
        def auto_actions(entity)
          [
            Engine::Action::Auto.new(
              entity,
              details: @game.corporations.select { |c| @game.destinated?(c) }.compact.map(&:id).join('/')
            ),
          ]
        end

        def actions(_entity)
          %w[auto]
        end

        def process_auto(action)
          action.details.split('/').map { |id| @game.corporation_by_id(id) }.each { |corp| @game.destinated!(corp) }
          pass!
        end
      end
    end
  end
end
