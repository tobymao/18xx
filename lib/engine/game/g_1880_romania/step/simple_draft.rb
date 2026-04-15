# frozen_string_literal: true

require_relative '../../g_1880/step/simple_draft'

module Engine
  module Game
    module G1880Romania
      module Step
        class SimpleDraft < G1880::Step::SimpleDraft
          attr_reader :minors

          def process_bid(action)
            minor = action.minor
            player = action.entity

            minor.owner = player
            minor.float!

            @minors.delete(minor)

            @log << "#{player.name} chooses #{minor.full_name} (#{minor.name})"

            # this line hijacks the BCR share assignment from 1880 China to assign to the TR instead
            assign_bcr_share_to_fi(action.entity, minor) if player.shares.find { |s| s.corporation.id == 'TR' }

            @round.next_entity_index!
            action_finalized
          end
        end
      end
    end
  end
end
