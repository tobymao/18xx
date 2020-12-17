# frozen_string_literal: true

require_relative '../base'
# require_relative '../../token'
# require_relative 'token_merger'

module Engine
  module Step
    module G1828
      class Merger < Base
        #        include TokenMerger
        ACTIONS = %w[merge].freeze

        def description
          "Select a corporation to merge with #{initiator.name}"
        end

        def actions(_entity)
          return [] unless initiator

          ACTIONS
        end

        def blocks?
          initiator
        end

        def process_merge(action)
          corporation = action.entity
          target = action.corporation
          @log << "Merging #{corporation.name} with #{target.name}"
        end

        def merging_corporation
          initiator
        end

        def merge_name
          'Merge'
        end

        def mergeable_type(corporation)
          "Corporations that can merge with #{corporation.name}"
        end

        def show_other_players
          false
        end

        def active_entities
          [@round.acting_player]
        end

        def initiator
          @round.merge_initiator
        end

        def round_state
          {
            merge_target: nil,
          }
        end

        def mergeable_entities(entity = @round.acting_player, corporation = initiator)
          return [] if corporation.owner != entity

          @game.corporations.select do |candidate|
            next if candidate == corporation ||
                    !candidate.ipoed ||
                    candidate.operated? != corporation.operated? ||
                    (!candidate.floated? && !corporation.floated?)

            # Mergeable not possible unless a player owns 5+ shares between the corporations
            @game.players.any? do |player|
              num_shares = player.num_shares_of(candidate) + player.num_shares_of(corporation)
              num_shares >= 6 ||
                (num_shares == 5 && !did_sell?(player, candidate) && !did_sell?(player, corporation))
            end
          end
        end
      end
    end
  end
end
