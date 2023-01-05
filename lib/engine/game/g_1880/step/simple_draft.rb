# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1880
      module Step
        class SimpleDraft < Engine::Step::Base
          attr_reader :minors, :choices

          ACTIONS = %w[bid].freeze

          def setup
            @minors = @game.minors.sort_by(&:id)
            @leftover_minors = @minors.size - @game.players.size
          end

          def available
            @minors
          end

          def may_purchase?(_company)
            true
          end

          def may_choose?(_company)
            true
          end

          def auctioning; end

          def bids
            {}
          end

          def visible?
            true
          end

          def players_visible?
            true
          end

          def name
            'Draft'
          end

          def description
            'Draft One Foreign Investor Each'
          end

          def finished?
            @leftover_minors == @minors.size
          end

          def actions(entity)
            return [] if finished?

            entity == current_entity ? ACTIONS : []
          end

          def process_bid(action)
            minor = action.minor
            player = action.entity

            puts("here in process, #{action.entity}")

            minor.owner = player
            minor.float!

            @minors.delete(minor)

            @log << "#{player.name} chooses #{minor.full_name} (#{minor.name})"

            @round.next_entity_index!
            action_finalized
          end

          def action_finalized
            return unless finished?

            @minors.each do |m|
              @log << "#{m.full_name} (#{m.name}) is removed from the game"
              m.close!
            end
            @round.reset_entity_index!
          end
        end
      end
    end
  end
end
