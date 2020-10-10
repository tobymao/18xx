# frozen_string_literal: true

require_relative '../assign'

module Engine
  module Step
    module G18MEX
      class Assign < Assign
        ACTIONS = %w[assign].freeze

        def actions(entity)
          return ACTIONS if entity == @game.ndm && ndm_merge_assign_ongoing?

          []
        end

        def active_entities
          [@game.ndm].compact
        end

        def active?
          ndm_merge_assign_ongoing?
        end

        def description
          'NdM Select Token to Convert'
        end

        def process_assign(action)
          @game.select_ndm_city(action.target)
        end

        def blocks?
          ndm_merge_assign_ongoing?
        end

        def available_hex(entity, hex)
          return if !ndm_merge_assign_ongoing? || entity != @game.ndm

          @game.merged_cities_to_select.find { |t| t.city.hex == hex }
        end

        private

        def ndm_merge_assign_ongoing?
          @game.merged_cities_to_select.any?
        end
      end
    end
  end
end
