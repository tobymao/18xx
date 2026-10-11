# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1833NE
      module Step
        class TakeoverCorporation < Engine::Step::Base
          #  The code below is a placeholder for now

          # def actions(entity)
          #   return [] if entity != current_entity
          #   return [] unless entity.corporation?
          #   return [] unless @round.view_merge_options

          #   %w[takeover pass]
          # end

          # def auto_actions(entity)
          #   return if entity != current_entity || !@round.view_merge_options || !@game.takeover_candidates(entity).empty?

          #   [Engine::Action::Pass.new(entity)]
          # end
        end
      end
    end
  end
end
