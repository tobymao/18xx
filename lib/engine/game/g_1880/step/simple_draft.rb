# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1880
      module Step
        class SimpleDraft < Engine::Step::SimpleDraft
          attr_reader :minors

          ACTIONS = %w[bid].freeze

          def setup
            @minors = @game.minors.sort_by(&:id)
            @leftover_minors = @minors.size - @game.players.size
          end

          def available
            @minors
          end

          def description
            'Draft One Foreign Investor Each'
          end

          def finished?
            @leftover_minors == @minors.size
          end

          def process_bid(action)
            minor = action.minor
            player = action.entity

            minor.owner = player
            minor.float!

            @minors.delete(minor)

            @log << "#{player.name} chooses #{minor.full_name} (#{minor.name})"

            assign_bcr_share_to_fi(action.entity, minor) if player.shares.find { |s| s.corporation.id == 'BCR' }

            @round.next_entity_index!
            action_finalized
          end

          def assign_bcr_share_to_fi(player, fi)
            @game.assign_share_to_fi(player.shares.first.corporation, fi)
          end

          def action_finalized
            return unless finished?

            @minors.each do |m|
              @log << "#{m.full_name} (#{m.name}) is removed from the game"
              m.tokens.first.remove!
              m.close!
            end
            @round.reset_entity_index!
          end
        end
      end
    end
  end
end
