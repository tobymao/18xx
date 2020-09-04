# frozen_string_literal: true

require_relative '../merger'

module Engine
  module Round
    module G1817
      class Merger < Merger
        def name
          'Merger and Acquisition Round'
        end

        def select_entities
          @game
            .corporations
            .select { |c| c.floated? && c.share_price.normal_movement? }
            .sort
        end

        def after_process(_action)
          return if !@converted || active_step

          @converted = nil
          entities.each(&:unpass!)
          next_entity_index!
          @steps.each(&:unpass!) unless @entity_index.zero?
        end

        def entities
          if @converted
            @game.players
          else
            @entities
          end
        end
      end
    end
  end
end
