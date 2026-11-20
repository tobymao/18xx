# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'takeover_offer'

module Engine
  module Game
    module G1833NE
      module Step
        class TakeoverCorporation < Engine::Step::Base
          include TakeoverOffer

          ACTIONS = %w[merge pass].freeze

          def actions(entity)
            return [] if entity != current_entity
            return [] if @game.takeover_candidates(entity).empty?

            ACTIONS
          end

          def round_state
            { takeover: nil }
          end

          def description
            'Takeover'
          end

          def pass_description
            'Pass (Takeover)'
          end

          def log_skip(_entity); end

          def merge_name(target = nil)
            target ? "Take over #{target.name}" : 'Take over'
          end

          def mergeable_type(entity)
            "Corporations #{entity.name} can take over"
          end

          def mergeable(entity)
            @game.takeover_candidates(entity)
          end

          def show_other_players
            true
          end

          def process_merge(action)
            acquirer = action.entity
            target = action.corporation
            raise GameError, "#{acquirer.name} cannot take over #{target&.name}" unless mergeable(acquirer).include?(target)

            @log << "#{acquirer.name} attempts to take over #{target.name}"
            pass!
            @round.takeover = { acquirer: acquirer, target: target, swaps: [], consented: false }
            advance_takeover!
          end
        end
      end
    end
  end
end
